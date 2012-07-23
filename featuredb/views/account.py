from pyramid.httpexceptions import HTTPFound
from pyramid.view import view_config

from featuredb.lib import security
from featuredb.views.base import ViewBase, get_row_dict
from featuredb.views import validators, register

import logging
log = logging.getLogger('featuredb.views.account')


class AccountSchema(register.UserDataSchema):
	Password = validators.String()
	ConfirmPassword = validators.String()


	chained_validators = [validators.FieldsMatch('Password', 'ConfirmPassword')
						  ]

_skip_fields = {'ConfirmPassword', 'Password'}
_fields = [x for x in AccountSchema.fields.keys() if x not in _skip_fields]
_password_hash_fields = ['PasswordHashRepeat', 'PasswordHashSalt', 'PasswordHash']

class Account(ViewBase):

	@view_config(route_name='account', renderer='account.mak', request_method="POST", permission='user')
	def save(self):
		request = self.request

		model_state = self.model_state
		
		model_state.schema = AccountSchema()

		if not model_state.validate():
			log.debug('validation error')
			request.errors = model_state.errors()
			return self._get_edit_info()

		password = model_state.value('Password')
		hash_args = [None, None, None]
		if password:
			salt = security.MakeSalt()
			hash = security.Crypt(salt, model_state.value('Password'))
			hash_args =  [security.DEFAULT_REPEAT, salt, hash]

		args = [model_state.value(x) for x in _fields] + hash_args
		kwargs = ', '.join(x.join(('@', '=?')) for x in _fields + _password_hash_fields)

		with request.connmgr.get_connection() as conn:
			sql = '''
				Declare @RC int, @ErrMsg nvarchar(500)
				EXEC @RC = sp_UpdateAccount ?, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC AS [Return], @ErrMsg AS ErrMsg''' % kwargs
			result = conn.execute(sql, request.user.Email, *args).fetchone()


		if result.Return:
			log.debug('Other Error: %s', result.ErrMsg)
			request.errors = tuple(result)
			model_state.add_error_for('*', result.ErrMsg)
			return self._get_edit_info()

		
		request.session['user'] = model_state.value('Email')
		request.session.flash('Account updated.')
		raise HTTPFound(location=request.route_url('account'))
		
	@view_config(route_name='account', renderer='account.mak', permission='user')
	def index(self):
		#request = self.request
		edit_info = self._get_edit_info()
		if not edit_info['user']:
			return HTTPFound(location=self.request.route_url('login'))

		self.model_state.form.data = get_row_dict(edit_info['user'])
		return edit_info
	
	def _get_edit_info(self):
		members = []
		agencies = []
		with self.request.connmgr.get_connection() as conn:
			cursor = conn.execute('EXEC sp_Account_Form ?', self.request.user.Email)

			user = cursor.fetchone()

			cursor.nextset()

			members = map(tuple,cursor.fetchall())

			cursor.nextset()

			agencies = [(code, title or code) for code,title in cursor.fetchall()]

			cursor.close()

			

		return {'agencies': agencies, 'members': members, 'user': user}




