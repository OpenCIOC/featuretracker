#stdlib
import logging

#3rd party
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound
from pyramid.security import remember, forget, NO_PERMISSION_REQUIRED
from formencode import Schema

#this app
from featuredb.views.base import ViewBase
from featuredb.views import validators
from featuredb.lib import security

log = logging.getLogger('featuredb.views.login')

class LoginSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None
	
	email= validators.String(max=50, not_empty=True)
	password = validators.String(not_empty=True)

class Login(ViewBase):
	@view_config(route_name="login", renderer='login.mak', request_method='POST', permission=NO_PERMISSION_REQUIRED)
	def login_process(self):
		request = self.request
		
		model_state = self.model_state
		model_state.schema = LoginSchema()

		if not model_state.validate():
			return {}
		
		with request.connmgr.get_connection() as conn:
			user = conn.execute('EXEC sp_User_Login ?', model_state.value('email')).fetchone()

		if not user:
			model_state.add_error_for('*', 'Email or password is incorrect')
			return {}

		hash = security.Crypt(user.PasswordHashSalt, model_state.value('password'), user.PasswordHashRepeat)
		if hash != user.PasswordHash:
			model_state.add_error_for('*', 'Email or password is incorrect')
			return {}

		request.session['user'] = user.Email
		request.session['bypass_login'] = None

		headers = remember(request, user.Email)

		return HTTPFound(location=request.route_url('search_index'), headers=headers)

	@view_config(context='pyramid.httpexceptions.HTTPForbidden', renderer="login.mak", permission=NO_PERMISSION_REQUIRED)
	@view_config(route_name='login', renderer='login.mak', permission=NO_PERMISSION_REQUIRED)
	def index(self):
		return {}

	@view_config(route_name='logout', permission=NO_PERMISSION_REQUIRED)
	def logout(self):
		request = self.request

		forget(request)
		request.session['bypass_login'] = None

		return HTTPFound(location=request.route_url('login'))

