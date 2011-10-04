from featuredb import modelstate

class ViewBase(object):
	__autoexpose__ = None

	def __init__(self, request):
		self.request = request
		self.model_state = request.model_state = modelstate.ModelState(request)

def get_row_dict(row):
	return dict(zip([d[0] for d in row.cursor_description], row))

