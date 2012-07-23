from pyramid.view import view_config

from featuredb.views.base import ViewBase

import logging
log = logging.getLogger('featuredb.views.suggestions')

class Suggestions(ViewBase):
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
