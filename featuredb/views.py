from pyramid_handlers import action
from formencode import Schema, validators

from featuredb import modelstate
from xml.etree import cElementTree as ET

import logging
log = logging.getLogger('featuredb.views')

MAX_ID = 2147483647

class UnicodeString(validators.UnicodeString):
	trim = True
	if_empty = None

class String(validators.String):
	trim = True
	if_empty = None

class IntID(validators.Int):
	if_empty = None
	min = 1
	max = MAX_ID

class SearchSchema(Schema):
	allow_extra_keys = True
	filter_extra_keys = False

	if_key_missing = None

	Terms = UnicodeString(max=100)
	Keyword = IntID()
	Module = String(max=1)
	UserPriority = IntID()
	SysPriority = IntID()
	Estimate = IntID()

field_order =  [
	'Keyword',
	'Module',
	'UserPriority',
	'Estimate',
	'SysPriority',
	'Terms',
	]

class Index(object):
	__autoexpose__ = None

	def __init__(self, request):
		self.request = request
		self.model_state = request.model_state = modelstate.ModelState(request)


	@action(renderer='search.mak')
	def index(self):
		request = self.request
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_SearchPage ?', None)

			keywords =  cursor.fetchall()

			cursor.nextset()

			modules = cursor.fetchall()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			estimates = cursor.fetchall()

			cursor.close()

		return dict(keywords=keywords, modules=modules, priorities=priorities, estimates=estimates)


	@action(renderer='results.mak')
	def results(self):
		request = self.request
		model_state = request.model_state

		model_state.schema = SearchSchema()
		model_state.form.method = None
		
		if not model_state.validate():
			# Validation Error
			request.override_renderer = 'search.mak'
			retval =  self.index()
			log.debug('errors: %s', model_state.form.errors)
			return retval

		with request.connmgr.get_connection() as conn:
			data = model_state.data
			args = [None] #XXX User Email
			args.extend(data.get(f) for f in field_order)
			cursor = conn.execute('EXEC dbo.sp_SearchResults %s' % ','.join('?' * len(args)), *args)

			searched_for = cursor.fetchone()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			cursor.close()

		searched_for = {d[0]: x for d,x in zip(searched_for.cursor_description, searched_for) if x}
		priorities = {x[0]: x for x in priorities}

		return dict(searched_for=searched_for, priorities=priorities, results=results)

	@action(renderer='priority.mak')
	def priority(self):

		return {}


	@action(renderer='login.mak')
	def login(self):
		return {}

	@action(name="login", renderer='login.mak', request_method='POST')
	def login_process(self):
		request = self.request


		return {}

	@action(renderer='register.mak')
	def register(self):
		request = self.request

		return {}

def _priority_xml_to_dict(pri):
	if not pri:
		return None

	root = ET.fromstring(pri)
	return root.attrib

def _xml_to_dict_list(modules):
	if not modules:
		return modules

	root = ET.fromstring(modules)
	return [x.attrib for x in root]

class Enhancement(object):
	__autoexpose__ = None

	def __init__(self, request):
		self.request = request
		self.model_state = request.model_state = modelstate.ModelState(request)


	@action(renderer='enhancement.mak')
	def index(self):
		request = self.request

		validator = IntID(not_empty=True)
		try:
			enh_id = validator.to_python(request.matchdict['id'])
		except validators.Invalid, e:
			# Change template?
			self.model_state.add_error_for('*', 'Invalid Enhancement: ' + e.message)
			return {}

		enhancement = None
		with request.connmgr.get_connection() as conn:
			enhancement = conn.execute('EXEC dbo.sp_EnhancementDetail ?, ?', None, enh_id).fetchone()

		if enhancement is None:
			#error condition, change template?
			self.model_state.add_error_for('*', 'No enhancement with ID %d' % enh_id)
			return {}

		enhancement.SysPriority = _priority_xml_to_dict(enhancement.SysPriority)
		enhancement.UserPriority = _priority_xml_to_dict(enhancement.UserPriority)
		enhancement.Modules = _xml_to_dict_list(enhancement.Modules)
		enhancement.Keywords = _xml_to_dict_list(enhancement.Keywords)


		return {'enhancement': enhancement, 'ErrMsg': None}
