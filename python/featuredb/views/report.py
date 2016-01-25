# =========================================================================================
#  Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from pyramid.view import view_config

from featuredb.views.base import ViewBase

import logging
log = logging.getLogger('featuredb.views.report')

class Report(ViewBase):
	@view_config(route_name='report', renderer='report.mak')
	def index(self):
		request = self.request
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Reporting ?', request.user and request.user.Email)

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			cursor.close()
			
		priority_map = {x[0]: x for x in priorities}

		return dict(results=results, priority_map=priority_map)
