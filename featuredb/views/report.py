from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.report')

class Report(ViewBase):
	@view_config(route_name='report', renderer='report.mak')
	def index(self):
		request = self.request
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Reporting ?', request.user)

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			cursor.close()
			
		priority_map = {x[0]: x for x in priorities}

		return dict(results=results, priority_map=priority_map)
