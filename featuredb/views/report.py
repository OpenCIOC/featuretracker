from pyramid.view import view_config

from featuredb.views.base import ViewBase

import logging
log = logging.getLogger('featuredb.views.report')

class Report(ViewBase):
	@view_config(route_name='report', renderer='report.mak')
	def index(self):
		request = self.request
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Reporting ?', request.user.Email)

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			cursor.close()
			
		priority_map = {x[0]: x for x in priorities}

		return dict(results=results, priority_map=priority_map)
