from pyramid.view import view_config
from xml.etree import cElementTree as ET

from featuredb.views.base import ViewBase
from featuredb.views import validators

def _priority_xml_to_dict(pri):
	if not pri:
		return None

	root = ET.fromstring(pri)
	return root.attrib

def _xml_to_dict_list(modules):
	if not modules:
		return modules

	root = ET.fromstring(modules)
	return [x.attrib for x in root]

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
		with request.connmgr.get_connection() as conn:
			enhancement = conn.execute('EXEC dbo.sp_EnhancementDetail ?, ?', request.user, enh_id).fetchone()

		if enhancement is None:
			#error condition, change template?
			self.model_state.add_error_for('*', 'No enhancement with ID %d' % enh_id)
			return {}

		enhancement.SysPriority = _priority_xml_to_dict(enhancement.SysPriority)
		enhancement.UserPriority = _priority_xml_to_dict(enhancement.UserPriority)
		enhancement.Modules = _xml_to_dict_list(enhancement.Modules)
		enhancement.Keywords = _xml_to_dict_list(enhancement.Keywords)


		return {'enhancement': enhancement, 'ErrMsg': None}

