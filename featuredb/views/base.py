#stdlib

#3rd party
from pyramid.security import NO_PERMISSION_REQUIRED
from pyramid.view import view_config

# this app
from featuredb.lib import modelstate

class ViewBase(object):
	__autoexpose__ = None

	def __init__(self, request):
		self.request = request
		self.model_state = request.model_state = modelstate.ModelState(request)

def get_row_dict(row):
	if not row:
		return {}
	return dict(zip([d[0] for d in row.cursor_description], row))


class ErrorPage(Exception):
	def __init__(self, title, message):
		self.title = title
		self.message = message


class ErrorPageController(ViewBase):
	def __init__(self, exception, request):
		ViewBase.__init__(self, request)
		self.exception = exception
	@view_config(context=ErrorPage, renderer='error.mak', permission=NO_PERMISSION_REQUIRED)
	def error_page(self):

		return {'page_title': self.exception.title, 'error_message': self.exception.message}

