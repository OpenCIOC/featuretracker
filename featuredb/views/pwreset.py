# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

from formencode import Schema

#this app
from .base import ViewBase
from ..lib import security, email
from . import validators

pwreset_email_template = u'''\
Hi %(FirstName)s,

Someone requested a password reset for the CIOC Feature Request Database site.
Your new password is:
%(Password)s

Please log in to %(url)s as soon as possible and change your password.
'''


class LoginSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	Email = validators.UnicodeString(max=50, not_empty=True)


class PwReset(ViewBase):
	@view_config(route_name="pwreset", request_method="POST", renderer='pwreset.mak', permission=NO_PERMISSION_REQUIRED)
	def post(self):
		request = self.request

		model_state = request.model_state
		model_state.schema = LoginSchema()

		if not model_state.validate():
			return {}

		password = security.MakeRandomPassword()

		salt = security.MakeSalt()
		hash = security.Crypt(salt, password)
		hash_args = [security.DEFAULT_REPEAT, salt, hash]

		Email = model_state.value('Email')
		user = None
		with request.connmgr.get_connection() as conn:
			user = conn.execute('EXEC sp_Users_u_PwReset ?, ?, ?, ?', Email, *hash_args).fetchone()

		if user:
			subject = 'CIOC Feature Request Database Site Password Reset'
			reset_message = pwreset_email_template % {
				'FirstName': user.FirstName,
				'Password': password,
				'url': request.route_url('login')
			}

			email.send_email(request, 'admin@cioc.ca', user.Email, subject, reset_message)

		request.session.flash('A new password was sent you your email address.')
		return HTTPFound(location=request.route_url('search_index'))

	@view_config(route_name="pwreset", renderer="pwreset.mak", permission=NO_PERMISSION_REQUIRED)
	def get(self):

		return {}
