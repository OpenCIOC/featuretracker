# stdlib
import logging

# 3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from formencode import Schema, ForEach

# this app
from featuredb.views.base import ViewBase, get_row_dict, ErrorPage
from featuredb.views import validators

log = logging.getLogger('featuredb.views.enhancementupdate')


class EnhancementSchema(Schema):
	if_key_missing = None

	allow_extra_fields = True
	filter_extra_fields = True

	Title = validators.String(max=255, not_empty=True)
	SYS_PRIORITY = validators.IntID(not_empty=True)
	SYS_ESTIMATE = validators.Int(min=0, max=15, not_empty=True)
	SYS_STATUS = validators.IntID(max=7, not_empty=True)
	SYS_FUNDER = validators.IntID()
	BasicDescription = validators.String(max=8000)
	AdditionalNotes = validators.String(max=2000)
	SYS_SOURCETYPE = validators.IntID()
	SourceDetail = validators.String(max=255)

	Modules = ForEach(validators.String(min=1, max=1))
	Keywords = ForEach(validators.IntID())

	Releases = ForEach(validators.IntID())
	SeeAlso = ForEach(validators.IntID())

	chained_validators = [validators.ForceRequire('Modules', 'Keywords')]


class Enhancement(ViewBase):

	@view_config(route_name='enhancementupdate', match_param='action=add', renderer='enhancementupdate.mak', request_method="POST", permission='admin')
	@view_config(route_name='enhancementupdate', match_param='action=edit', renderer='enhancementupdate.mak', request_method="POST", permission='admin')
	def save(self):
		request = self.request
		user = request.user

		action = request.matchdict.get('action')
		is_add = action == 'add'

		extra_validators = {}
		model_state = request.model_state

		if not is_add:
			extra_validators['ID'] = validators.IntID(not_empty=True)

		model_state.schema = EnhancementSchema(**extra_validators)

		if model_state.validate():
			if not is_add:
				ID = model_state.value('ID')
			else:
				ID = None

			args = [ID, user.Email]
			args.extend(model_state.value(k) for k in ['Title', 'BasicDescription', 'AdditionalNotes', 'SYS_ESTIMATE', 'SYS_FUNDER', 'SYS_PRIORITY', 'SYS_STATUS', 'SYS_SOURCETYPE', 'SourceDetail'])
			args.extend(','.join(map(str, model_state.value(k))) for k in ['Modules', 'Keywords', 'Releases', 'SeeAlso'])

			with request.connmgr.get_connection() as conn:
				sql = '''DECLARE @RC int, @ErrMsg nvarchar(500), @EnhID int
					SET @EnhID = ?
					EXEC @RC = sp_Enhancement_Update @EnhID OUTPUT, %s, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg, @EnhID AS [ID]''' % ','.join('?' * (len(args) - 1))

				result = conn.execute(sql, args).fetchone()

				if not result.ErrMsg:
					raise HTTPFound(location=request.current_route_url(action='edit', _query=[('ID', result.ID)]))

				model_state.add_error_for('*', result.ErrMsg)

		else:
			if not is_add and model_state.is_error('ID'):
				raise ErrorPage('Update Enhancement', 'Invalid ID')

		edit_info = self._get_edit_info(model_state.value('ID'), is_add, ','.join(request.POST.getall('SeeAlso')))

		data = model_state.form.data
		data['Keywords'] = request.POST.getall('Keywords')
		data['Modules'] = request.POST.getall('Modules')
		data['Releases'] = request.POST.getall('Releases')
		data['SeeAlso'] = request.POST.getall('SeeAlso')

		return edit_info

	@view_config(route_name='enhancementupdate', match_param='action=add', renderer='enhancementupdate.mak', permission='admin')
	@view_config(route_name='enhancementupdate', match_param='action=edit', renderer='enhancementupdate.mak', permission='admin')
	def edit(self):
		request = self.request

		action = request.matchdict.get('action')
		is_add = action == 'add'

		ID = None
		if not is_add:
			validator = validators.IntID(not_empty=not is_add)
			try:
				ID = validator.to_python(request.params.get('ID'))
			except validators.Invalid:
				raise ErrorPage('Update Enhancement', 'Invalid ID')

		edit_info = self._get_edit_info(ID, is_add)

		if not is_add:
			data = self.model_state.form.data = get_row_dict(edit_info['enhancement'])
			data['Keywords'] = [unicode(x.KEYWORD_ID) for x in edit_info['keywords'] if x.IS_SELECTED]
			data['Modules'] = [unicode(x.MODULE_ID) for x in edit_info['modules'] if x.IS_SELECTED]
			data['Releases'] = [unicode(x.RELEASE_ID) for x in edit_info['releases'] if x.IS_SELECTED]
			data['SeeAlso'] = [unicode(x.ID) for x in edit_info['see_alsos']]

		return edit_info

	def _get_edit_info(self, ID, is_add, extra_see_also=None):
		enhancement = None
		with self.request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_Enhancement_Form ?, ?', ID, extra_see_also)

			enhancement = cursor.fetchone()

			if not is_add and not enhancement:
				raise ErrorPage('Update Enhancement', 'No enhancement with ID %d' % ID)

			cursor.nextset()
			priorities = cursor.fetchall()

			cursor.nextset()
			estimates = cursor.fetchall()

			cursor.nextset()
			funders = cursor.fetchall()

			cursor.nextset()
			statuses = cursor.fetchall()

			cursor.nextset()
			source_types = cursor.fetchall()

			cursor.nextset()
			keywords = cursor.fetchall()

			cursor.nextset()
			modules = cursor.fetchall()

			cursor.nextset()
			releases = cursor.fetchall()

			cursor.nextset()
			see_alsos = cursor.fetchall()

			cursor.close()

		return dict(
			is_add=is_add, enhancement=enhancement,
			priorities=priorities, estimates=estimates, funders=funders,
			statuses=statuses, source_types=source_types, keywords=keywords, modules=modules,
			releases=releases, see_alsos=see_alsos)

	@view_config(route_name='enhancementupdate', match_param='action=getenh', renderer='json', permission='admin')
	def getenhancement(self):
		request = self.request

		ID = None
		validator = validators.IntID(not_empty=True)
		try:
			ID = validator.to_python(request.params.get('ID'))
		except validators.Invalid:
			return {'success': False, 'errmsg': 'Invalid ID'}

		with request.connmgr.get_connection() as conn:
			result = conn.execute('SELECT ID, Title FROM Enhancement WHERE ID=?', ID).fetchone()

		if not result:
			return {'success': False, 'errmsg': 'No enhancemnt with given ID'}

		return {'success': True, 'ID': result.ID, 'Title': result.Title}
