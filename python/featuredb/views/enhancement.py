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
from xml.etree import cElementTree as ET

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

from markupsafe import escape, Markup

def _priority_xml_to_dict(pri):
	if not pri:
		return None

	root = ET.fromstring(pri)
	return root.attrib

def _xml_to_dict_list(modules):
	if not modules:
		return []

	root = ET.fromstring(modules)
	return [x.attrib for x in root]

def _make_html(text):
	if not text:
		return None

	return escape(text).replace('\r', '').replace('\n', Markup('<br>'))

@view_config(route_name='enhancement', renderer='enhancement.mak')
class Enhancement(ViewBase):


	def __call__(self):
		request = self.request

		validator = validators.IntID(not_empty=True)
		try:
			enh_id = validator.to_python(request.matchdict['id'])
		except validators.Invalid, e:
			# Change template?
			self.model_state.add_error_for('*', 'Invalid Enhancement: ' + e.message)
			return {}

		enhancement = None
		priorities = []
		user_priorities = []
		user_cart = {}
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Enhancement_Detail ?, ?', request.user and request.user.Email, enh_id)

			enhancement = cursor.fetchone()
			if request.user:
				cursor.nextset()
				priorities = cursor.fetchall()

				cursor.nextset()
				user_priorities = cursor.fetchall()

				cursor.nextset()
				user_cart = get_row_dict(cursor.fetchone())

			cursor.close()

		if enhancement is None:
			#error condition, change template?
			self.model_state.add_error_for('*', 'No enhancement with ID %d' % enh_id)
			return {'priorities': priorities, 'user_priorities': user_priorities}

		enhancement.SysPriority = _priority_xml_to_dict(enhancement.SysPriority)
		enhancement.UserPriority = _priority_xml_to_dict(enhancement.UserPriority)
		enhancement.AvgRating = _priority_xml_to_dict(enhancement.AvgRating)
		enhancement.Modules = _xml_to_dict_list(enhancement.Modules)
		enhancement.Keywords = _xml_to_dict_list(enhancement.Keywords)
		enhancement.SeeAlsos = _xml_to_dict_list(enhancement.SeeAlsos)
		enhancement.Releases = _xml_to_dict_list(enhancement.Releases)

		enhancement.BasicDescription = _make_html(enhancement.BasicDescription)
		enhancement.AdditionalNotes = _make_html(enhancement.AdditionalNotes)

		search_ids = request.session.get('search_ids')

		enh_nav = []
		if search_ids:
			try:
				idx = search_ids.index(enhancement.ID)
				if idx != 0:
					enh_nav.append(('< prev', search_ids[idx-1]))

				if idx != len(search_ids)-1:
					enh_nav.append(('next >', search_ids[idx+1]))
			except ValueError:
				pass

		return {'enhancement': enhancement, 'enh_nav': enh_nav, 'cart': user_cart,
		  'priorities': priorities, 'user_priorities': user_priorities}

