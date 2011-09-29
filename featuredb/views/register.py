from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.search')

class Register(ViewBase):

	@action(renderer='register.mak')
	def index(self):
		request = self.request

		return {}
