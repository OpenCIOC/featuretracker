from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from formencode import Schema

from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.suggest')


class SuggestionSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None
	
	Suggestion = validators.UnicodeString(not_empty=True)



class Suggest(ViewBase):

	@view_config(route_name='suggest', renderer='suggest.mak', request_method="POST")
	def save(self):
		request = self.request

		model_state = self.model_state
		
		model_state.schema = SuggestionSchema()

		if not model_state.validate():
			log.debug('validation error')
			request.errors = model_state.errors()
			return {}
	
		with request.connmgr.get_connection() as conn:
			sql = '''
				Declare @RC int, @ErrMsg nvarchar(500)
				EXEC @RC = sp_Suggest ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC AS [Return], @ErrMsg AS ErrMsg'''
			result = conn.execute(sql, request.user, model_state.value('Suggestion')).fetchone()


		if result.Return:
			model_state.add_error_for('*', result.ErrMsg)
			return self._get_edit_info()

		
		request.session.flash('Thank you for your suggestion')
		raise HTTPFound(location=request.route_url('search_index'))
		
	@view_config(route_name='suggest', renderer='suggest.mak')
	def index(self):

		return {}
	


