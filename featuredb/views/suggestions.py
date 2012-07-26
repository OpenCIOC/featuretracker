#stdlib
import logging

#3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config

#this app
from featuredb.views import validators
from featuredb.views.base import ViewBase, ErrorPage

log = logging.getLogger('featuredb.views.suggestions')

class Suggestions(ViewBase):
	@view_config(route_name='suggestions', renderer='suggestions.mak', permission='admin')
	def index(self):
		log.debug('suggestions')
		request = self.request
		
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC dbo.sp_Suggest_List')

			suggestions = cursor.fetchall()

			cursor.close()
			
		return dict(suggestions=suggestions)


	@view_config(route_name='suggestion_delete', renderer='delete_confirm.mak', request_method='POST', permission='admin')
	def delete(self):
		log.debug('delete')
		request = self.request

		validator = validators.IntID
		try:
			ID = validator.to_python(request.params.get('ID'))
		except validators.Invalid:
			raise ErrorPage('Delete Suggestion', 'Invalid ID')

		with request.connmgr.get_connection() as conn:
			sql = '''DECLARE @RC int, @ErrMsg nvarchar(500)
					EXEC @RC = dbo.sp_Suggest_Delete ?, @ErrMsg OUTPUT
					SELECT @RC AS [Return], @ErrMsg AS ErrMsg
					'''

			result = conn.execute(sql, ID).fetchone()

			if result.Return:
				raise ErrorPage('Delete Suggestion', result.ErrMsg)

		raise HTTPFound(location=request.route_url('suggestions'))

	@view_config(route_name='suggestion_delete', renderer='delete_confirm.mak', permission='admin')
	def delete_confirm(self):
		log.debug('delete_confirm')
		request = self.request

		validator = validators.IntID
		try:
			ID = validator.to_python(request.params.get('ID'))
		except validators.Invalid:
			raise ErrorPage('Delete Suggestion', 'Invalid ID')

		return dict(page_title='Delete Suggestion', ID=ID)

