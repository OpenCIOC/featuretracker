from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.search')

class SearchSchema(Schema):
	allow_extra_keys = True
	filter_extra_keys = False

	if_key_missing = None

	Terms = validators.UnicodeString(max=100)
	Keyword = validators.IntID()
	Module = validators.String(max=1)
	UserPriority = validators.IntID()
	SysPriority = validators.IntID()
	Estimate = validators.Int(min=0, max=32767)
	IncludeClosed = validators.Bool()

field_order =  [
	'Keyword',
	'Module',
	'UserPriority',
	'Estimate',
	'SysPriority',
	'IncludeClosed',
	'Terms',
	]

class Search(ViewBase):
	@action(renderer='search.mak')
	def index(self):
		request = self.request
		user_priorities = []
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_SearchPage ?', request.user)

			keywords =  cursor.fetchall()

			cursor.nextset()

			modules = cursor.fetchall()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			estimates = cursor.fetchall()

			if request.user:
				cursor.nextset()
				user_priorities = cursor.fetchall()

			cursor.close()

		return dict(keywords=keywords, modules=modules, priorities=priorities,
			  estimates=estimates, user_priorities=user_priorities)


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

		user_priorities = []
		with request.connmgr.get_connection() as conn:
			data = model_state.data
			args = [request.user] 
			args.extend(data.get(f) for f in field_order)
			cursor = conn.execute('EXEC dbo.sp_SearchResults %s' % ','.join('?' * len(args)), *args)

			searched_for = cursor.fetchone()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			if request.user:
				cursor.nextset()
				user_priorities = cursor.fetchall()

			cursor.close()

		searched_for = {d[0]: x for d,x in zip(searched_for.cursor_description, searched_for) if x}
		priority_map = {x[0]: x for x in priorities}

		return dict(searched_for=searched_for, priorities=priorities,
			  results=results, user_priorities=user_priorities, priority_map=priority_map)
