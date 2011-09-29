from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.login')

class LoginSchema(Schema):

	email= validators.String(max=50)

class Login(ViewBase):
	@action(renderer='login.mak')
	def index(self):
		return {}

	@action(name="index", renderer='login.mak', request_method='POST')
	def login_process(self):
		request = self.request


		return {}

