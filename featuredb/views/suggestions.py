from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.suggestions')

class Report(ViewBase):
	@view_config(route_name='suggestions', renderer='suggestions.mak')
	def index(self):
		request = self.request
		user = request.user
		
		#if not (user.TechAdmin):
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Suggestion')

			suggestions = cursor.fetchall()

			cursor.close()
			
		return dict(suggestions=suggestions)
