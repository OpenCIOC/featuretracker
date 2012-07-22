from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from formencode import Schema, ForEach, All, Pipe

from featuredb import security
from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators

import logging
log = logging.getLogger('featuredb.views.enhancementupdate')

class EnhancementSchema(Schema):
	if_key_missing = None
	
	allow_extra_fields = True
	filter_extra_fields = True
	
	Title = validators.String(max=255, not_empty=True)
	SYS_PRIORITY = validators.IntID()
	SYS_ESTIMATE = validators.IntID(not_empty=True)
	SYS_STATUS = validators.IntID(not_empty=True)
	SYS_FUNDER = validators.IntID()
	BasicDescription = validators.String(max=2000)
	AdditionalNotes = validators.String(max=2000)
	SYS_SOURCETYPE = validators.IntID()
	SourceDetail = validators.String(max=255)
	
	Modules = ForEach(validators.IntID())
	Keywords = ForEach(validators.IntID())

	Releases = ForEach(validators.IntID())
	SeeAlso = ForEach(validators.IntID())

	chained_validators=[validators.ForceRequire('Modules','Keywords')]

class Enhancement(ViewBase):

	@view_config(route_name='enhancementupdate', match_param='action=add', renderer='enhancementupdate.mak', request_method="POST")
	@view_config(route_name='enhancementupdate', match_param='action=edit', renderer='enhancementupdate.mak', request_method="POST")
	def save(self):
		request = self.request
		user = request.user
		
		#if not (user.TechAdmin):
		
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
		args.extend(model_state.value(k) for k in ('Title','SYS_PRIORITY','SYS_ESTIMATE','SYS_STATUS','SYS_FUNDER','BasicDescription','AdditionalNotes','SYS_SOURCETYPE','SourceDetail'))
		args.extend(','.join(model_state.value(k)) for k in ('Modules','Keywords','Releases','SeeAlso'))
		
	@view_config(route_name='enhancementupdate', match_param='action=add', renderer='enhancementupdate.mak')
	@view_config(route_name='enhancementupdate', match_param='action=edit', renderer='enhancementupdate.mak')
	def edit(self):
		request = self.request
		user = request.user

		#if not (user.TechAdmin):

		members = []
		agencies = []
		with self.request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_Enhancement_Form ?', self.request.user)

			user = cursor.fetchone()

			cursor.nextset()

			members = map(tuple,cursor.fetchall())

			cursor.nextset()

			agencies = [(code, title or code) for code,title in cursor.fetchall()]

			cursor.close()
			

		return {'agencies': agencies, 'members': members, 'user': user}




