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

#Python STD Lib
from datetime import date, datetime, time

import logging

# 3rd party libs
from pyramid.request import Request
from pyramid.decorator import reify
from pyramid.security import unauthenticated_userid

from babel import Locale, dates

# This app
from featuredb.lib import config, connection, const

log = logging.getLogger(__name__)

class CommunityManagerRequest(Request):
	@reify
	def config(self):
		return config.get_config(const._config_file)

	@reify
	def connmgr(self):
		return connection.ConnectionManager(self)

	@reify
	def user(self):
		# <your database connection, however you get it, the below line
		# is just an example>
		userid = unauthenticated_userid(self)
		if userid is not None:
			# this should return None if the user doesn't exist
			# in the database
			with self.connmgr.get_connection() as conn:
				user = conn.execute('EXEC sp_User_Login ?', userid).fetchone()

			return user

		return None

	def format_date(self, d):
		return format_date(d, self)

	def format_time(self, t):
		return format_time(t, self)

	def format_datetime(self, dt):
		return format_datetime(dt, self)


_locale = None
def get_locale(request):
	global _locale
	if not _locale:
		_locale = Locale.parse('en-CA', sep='-')

	return _locale

_date_format = 'd MMM yyyy'
def format_date(d, request):
	if d is None:
		return ''
	if not isinstance(d, (date, datetime)):
		return d

	l = get_locale(request)
	format = _date_format
	return dates.format_date(d, locale=l, format=format)

def format_time(t, request):
	if t is None:
		return ''
	if not isinstance(t, (datetime, time)):
		return t

	l = get_locale(request)
	return dates.format_time(t, locale=l)

def format_datetime(dt, request):
	if dt is None:
		return ''
	if not isinstance(dt, (date, datetime, time)):
		return dt

	parts = []

	if isinstance(dt, (date, datetime)):
		parts.append(format_date(dt, request))

	if isinstance(dt, (datetime, time)):
		parts.append(format_time(dt, request))

	return ' '.join(parts)
