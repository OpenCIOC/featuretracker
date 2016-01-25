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

from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.concerns')

class Report(ViewBase):
	@view_config(route_name='concerns', renderer='concerns.mak', permission='admin')
	def index(self):
		request = self.request
		user = request.user
		
		#if not (user.TechAdmin):
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Enhancement_Concerns')

			concerns = cursor.fetchall()

			cursor.close()
			
		return dict(concerns=concerns)
