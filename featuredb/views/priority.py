from pyramid_handlers import action
from formencode import Schema

from featuredb.views.base import ViewBase
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.priority')


class Priority(ViewBase):
	__autoexpose__ = None


	@action(renderer='priority.mak')
	def index(self):

		return {}

