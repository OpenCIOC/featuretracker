from itertools import groupby
from operator import attrgetter
from xml.etree import cElementTree as ET

from pyramid.view import view_config
from formencode import Schema, ForEach

from featuredb.views.base import ViewBase, get_row_dict as _get_dict
from featuredb.views import validators

import json

import logging
log = logging.getLogger('featuredb.views.priority')

class UserPrioritySchema(Schema):

	id = validators.IntID(not_empty=True)
	enhancements = ForEach(validators.IntID())


class MultiPrioritySchema(Schema):
	priorities = ForEach(UserPrioritySchema())

def _fix_user_cart(user_cart):
	if not any(user_cart):
		user_cart = None
	else:
		for i, val in enumerate(user_cart):
			user_cart[i] = str(val)
		user_cart = _get_dict(user_cart)


	return user_cart
class Priority(ViewBase):
	
	@view_config(route_name='priority', request_method='POST', renderer='json')
	def save(self):
		request = self.request

		if not request.user:
			# not logged in, can't do anything
			return {}

		priorities = json.loads(request.body)
		data = {'priorities': priorities}



		schema = MultiPrioritySchema()

		try:
			parsed_data = schema.to_python(data)
		except validators.Invalid, e:
			# XXX error
			return {'failed': True, 'message': e.message}

		priorities = parsed_data['priorities']
		root = ET.Element('priorities')

		for priority in priorities:
			el = ET.SubElement(root, 'priority', id=unicode(priority['id']))
			for cnt,enhid in enumerate(priority['enhancements'] or []):
				ET.SubElement(el, 'enh', id=unicode(enhid), cnt=unicode(cnt))

		xml = ET.tostring(root)

		with request.connmgr.get_connection() as conn:
			sql = '''Declare @RC int, @ErrMsg nvarchar(500), @Email varchar(60)
					SET @Email = ?
					 EXEC @RC = sp_UpdateUserPriorities @Email, ?, @ErrMsg OUTPUT

					 SELECT @RC AS [Return], @ErrMsg AS ErrMsg
					 
					 EXEC sp_UserCart @Email '''
			cursor = conn.execute(sql, request.user, xml)
			
			result = cursor.fetchone()

			cursor.nextset()

			user_cart = cursor.fetchone()

			cursor.close()


		if result.Return:
			#XXX error
			return {'failed': True, 'message': result.ErrMsg}

		return {'failed': False, 'cart': _fix_user_cart(user_cart)}

	@view_config(route_name='priority', renderer='json')
	def index(self):
		request = self.request

		if not request.user:
			# not logged in, can't do anything
			return {}

		with request.connmgr.get_connection() as conn:
			priorities = conn.execute('EXEC sp_UserPriorities ?', request.user).fetchall()
			user_cart = conn.execute('EXEC sp_UserCart ?', request.user).fetchone()

		
		priorities = {k: map(_get_dict, g) for k,g in groupby(priorities, attrgetter('PRIORITY_ID'))}



		return dict(priorities=priorities, cart = _fix_user_cart(user_cart))





