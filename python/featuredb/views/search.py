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

from datetime import date, timedelta

from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound
from formencode import Schema

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.search')

class SearchSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	Terms = validators.UnicodeString(max=100)
	Keyword = validators.IntID()
	Module = validators.String(max=1)
	UserPriority = validators.IntID()
	SysPriority = validators.IntID()
	Estimate = validators.Int(min=0, max=32767)
	IncludeClosed = validators.Bool()
	CreatedInTheLastXDays = validators.Int(min=1, max=32767)
	ModifiedInTheLastXDays = validators.Int(min=1, max=32767)
	Release	= validators.IntID()
	Funder = validators.Int(min=-1, max=32767)
	Status = validators.IntID()
	ID = validators.IntID()

field_order =  [
	'Keyword',
	'Module',
	'UserPriority',
	'Estimate',
	'SysPriority',
	'Release',
	'Funder',
	'Status',
	'IncludeClosed',
	'Terms',
	]

class Search(ViewBase):
	@view_config(route_name="search_index", renderer='search.mak')
	def index(self):
		request = self.request
		user_priorities = []
		user_cart = {}
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Search_Page ?', request.user and request.user.Email)

			keywords =  cursor.fetchall()

			cursor.nextset()

			modules = cursor.fetchall()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			estimates = cursor.fetchall()

			cursor.nextset()

			releases = cursor.fetchall()
			
			cursor.nextset()
			
			funders = cursor.fetchall()
			
			cursor.nextset()
			
			statuses = cursor.fetchall()

			if request.user:
				cursor.nextset()
				user_priorities = cursor.fetchall()

				cursor.nextset()
				user_cart = get_row_dict(cursor.fetchone())

			cursor.close()

		return dict(keywords=keywords, modules=modules, priorities=priorities,
			  estimates=estimates, user_priorities=user_priorities, releases=releases,
			  funders=funders, statuses=statuses, cart=user_cart)


	@view_config(route_name='search_results', renderer='results.mak')
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
		user_cart = {}

		data = model_state.data
		
		enhid = data.get('ID')
		if enhid:
			return HTTPFound(location=request.route_url('enhancement', id=enhid))

		with request.connmgr.get_connection() as conn:

			args = [request.user and request.user.Email] 
			args.extend(data.get(f) for f in field_order)

			created_in_the_last_number = data.get('CreatedInTheLastXDays')
			if created_in_the_last_number:
				created_in_the_last = date.today()-timedelta(created_in_the_last_number)
			else:
				created_in_the_last = None
			args.append(created_in_the_last)
				
			modified_in_the_last_number = data.get('ModifiedInTheLastXDays')
			if modified_in_the_last_number:
				modified_in_the_last = date.today()-timedelta(modified_in_the_last_number)
			else:
				modified_in_the_last = None
			args.append(modified_in_the_last)
			
			cursor = conn.execute('EXEC dbo.sp_Search_Results %s' % ','.join('?' * len(args)), *args)

			searched_for = cursor.fetchone()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			results = cursor.fetchall()

			if request.user:
				cursor.nextset()
				user_priorities = cursor.fetchall()

				cursor.nextset()
				user_cart = get_row_dict(cursor.fetchone())

			cursor.close()

		searched_for = {d[0]: x for d,x in zip(searched_for.cursor_description, searched_for) if x}
		priority_map = {x[0]: x for x in priorities}

		include_closed = data.get('IncludeClosed')
		fulltext_keywords = data.get('Terms')

		request.session['search_ids'] = [x.ID for x in results]


		return dict(searched_for=searched_for, priorities=priorities, cart=user_cart, 
			 results=results, user_priorities=user_priorities, priority_map=priority_map, 
			 include_closed=include_closed, fulltext_keywords=fulltext_keywords, 
			 created_in_the_last_number=created_in_the_last_number, modified_in_the_last_number=modified_in_the_last_number)
