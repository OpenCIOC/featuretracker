from pyramid_handlers import action
from formencode import Schema

from featuredb import modelstate

class SearchSchema(Schema):
	pass


class Index(object):
	__autoexpose__ = None

	def __init__(self, request):
		self.request = request
		self.model_state = request.model_state = modelstate.ModelState(request)


	@action(renderer='search.mak')
	def index(self):
		request = self.request
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_SearchPage ?', None)

			keywords =  cursor.fetchall()

			cursor.nextset()

			modules = cursor.fetchall()

			cursor.nextset()

			priorities = cursor.fetchall()

			cursor.nextset()

			estimates = cursor.fetchall()

			cursor.close()

		return dict(keywords=keywords, modules=modules, priorities=priorities, estimates=estimates)


	@action(renderer='results.mak')
	def results(self):
		request = self.request
		return {}

	@action(renderer='priority.mak')
	def priority(self):
		request = self.request

		return {}
