#stdlib
import logging

#3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from formencode import Schema

#this app
from featuredb.lib.email import send_email
from featuredb.views.base import ViewBase
from featuredb.views import validators

log = logging.getLogger('featuredb.views.suggest')

new_suggestion_email_template = u'''\
Hi Admins,

%(Email)s just added a new Enhancement Suggestion:

%(Suggestion)s

Thanks,
The CIOC Feature Database
'''

class SuggestionSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None
	
	Suggestion = validators.UnicodeString(not_empty=True)


class Suggest(ViewBase):

	@view_config(route_name='suggest', renderer='suggest.mak', request_method="POST", permission='loggedin')
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
			result = conn.execute(sql, request.user.Email, model_state.value('Suggestion')).fetchone()


		if result.Return:
			model_state.add_error_for('*', result.ErrMsg)
			return self._get_edit_info()

		
		with request.connmgr.get_connection() as conn:
			addresses = conn.execute('EXEC sp_User_Admin_l').fetchall()

		if addresses:
			email_msg = new_suggestion_email_template % {'Email': request.user.Email, 
												'Suggestion': model_state.value('Suggestion')}

			send_email(request, 'admin@cioc.ca', [x.Email for x in addresses], 'New Feature Suggestion', email_msg, reply=request.user.Email)

		request.session.flash('Thank you for your suggestion')
		raise HTTPFound(location=request.route_url('search_index'))
		
	@view_config(route_name='suggest', renderer='suggest.mak', permission='loggedin')
	def index(self):

		return {}
	


