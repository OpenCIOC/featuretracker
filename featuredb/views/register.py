#stdlib
import logging

#3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config
from pyramid.security import NO_PERMISSION_REQUIRED
from formencode import Schema, All, Pipe

#this app
from featuredb.lib import security
from featuredb.views.base import ViewBase
from featuredb.views import validators

log = logging.getLogger('featuredb.views.register')


class UserDataSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	Email = All(validators.MaxLength(50), validators.Email(not_empty=True))
	Member = validators.IntID()
	Agency = validators.AgencyCode()

	OrgName = validators.String(max=150)
	FirstName = validators.String(max=50)
	LastName = validators.String(max=50)

class RegistrationSchema(UserDataSchema):
	Password = validators.String(not_empty=True)
	ConfirmPassword = validators.String(not_empty=True)

	TomorrowsDate = Pipe(validators.DateConverter(month_style='dd/mm/yyyy', not_empty=True), validators.TomorrowsDate(not_empty=True))


	chained_validators = [validators.FieldsMatch('Password', 'ConfirmPassword')]

_skip_fields = {'ConfirmPassword','TomorrowsDate', 'Password'}
_fields = [x for x in RegistrationSchema.fields.keys() if x not in _skip_fields]
_password_hash_fields = ['PasswordHashRepeat', 'PasswordHashSalt', 'PasswordHash']

class Register(ViewBase):

	@view_config(route_name='register', renderer='register.mak', request_method="POST", permission=NO_PERMISSION_REQUIRED)
	def save(self):
		request = self.request

		model_state = self.model_state
		
		model_state.schema = RegistrationSchema()

		if not model_state.validate():
			log.debug('validation error')
			request.errors = model_state.errors()
			return self._get_edit_info()
	
		salt = security.MakeSalt()
		hash = security.Crypt(salt, model_state.value('Password'))
		hash_args =  [security.DEFAULT_REPEAT, salt, hash]
		args = [model_state.value(x) for x in _fields] + hash_args
		kwargs = ', '.join(x.join(('@', '=?')) for x in _fields + _password_hash_fields)
		with request.connmgr.get_connection() as conn:
			sql = '''
				Declare @RC int, @ErrMsg nvarchar(500)
				EXEC @RC = sp_Register %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC AS [Return], @ErrMsg AS ErrMsg''' % kwargs
			result = conn.execute(sql, args).fetchone()


		if result.Return == 2:
			pass #XXX Password recovery
			log.debug('Password Recovery: %s', result.ErrMsg)
			request.errors = tuple(result)
			model_state.add_error_for('*', result.ErrMsg)
			return self._get_edit_info()

		elif result.Return:
			log.debug('Other Error: %s', result.ErrMsg)
			request.errors = tuple(result)
			model_state.add_error_for('*', result.ErrMsg)
			return self._get_edit_info()

		
		request.session['user'] = model_state.value('Email')
		request.session.flash('Thanks for registering.')
		raise HTTPFound(location=request.route_url('search_index'))
		
	@view_config(route_name='register', renderer='register.mak', permission=NO_PERMISSION_REQUIRED)
	def index(self):
		#request = self.request

		return self._get_edit_info()
	
	def _get_edit_info(self):
		members = []
		agencies = []
		with self.request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_Register_Form')

			members = map(tuple,cursor.fetchall())

			cursor.nextset()

			agencies = [(code, title or code) for code,title in cursor.fetchall()]

			cursor.close()

		return {'agencies': agencies, 'members': members}



