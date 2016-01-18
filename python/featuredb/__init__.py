# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

# stdlib
import logging

# 3rd party
from pyramid.config import Configurator
from pyramid.decorator import reify
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import NO_PERMISSION_REQUIRED, Authenticated, Everyone, Allow, DENY_ALL

from redis import ConnectionPool

# this app
from featuredb.lib import const, config as ciocconfig

log = logging.getLogger(__name__)

app_path = None
config_file = None
app_name = None


def groupfinder(userid, request):
	user = request.user

	if user is not None:
		groups = []

		if user.TechAdmin:
			groups.append('group:TechAdmin')

		return groups

	return None


class RootFactory(object):
	@reify
	def __acl__(self):
		request = self.request

		acl = [(Allow, 'group:TechAdmin', ('loggedin', 'admin', 'public')), (Allow, Authenticated, ('loggedin', 'public'))]

		has_bypass = False
		if not request.user:
			if request.params.get('bypass_login'):
				request.session['bypass_login'] = True
				has_bypass = True

			elif request.session.get('bypass_login'):
				has_bypass = True

		if has_bypass:
			acl.append((Allow, Everyone, 'public'))

		acl.append(DENY_ALL)

		return acl

	def __init__(self, request):
		self.request = request


def get_redis_pool(config):
	url = config.get('session.url', '172.23.16.12:6379')

	host, port = url.split(':')
	redispool = ConnectionPool(host=host, port=int(port))

	return redispool


def get_session_settings(cnf, settings):
	settings['redis.sessions.connection_pool'] = get_redis_pool(cnf)

	session_secret = cnf.get('session.secret')
	if session_secret:
		settings['redis.sessions.secret'] = session_secret

	settings['redis.sessions.prefix'] = const._app_name + '-session:'

	cookie_secure = cnf.get('session.cookie_secure')
	if cookie_secure:
		settings['redis.sessions.cookie_secure'] = cookie_secure


def main(global_config, **settings):
	""" This function returns a Pyramid WSGI application.
	"""

	const.update_cache_values()
	cnf = ciocconfig.get_config(const._config_file)

	get_session_settings(cnf, settings)

	settings['mako.imports'] = ['from markupsafe import escape_silent']
	settings['mako.default_filters'] = ['escape_silent']

	authn_policy = SessionAuthenticationPolicy(callback=groupfinder)
	authz_policy = ACLAuthorizationPolicy()

	config = Configurator(
		settings=settings,
		root_factory=RootFactory,
		default_permission='public',
		request_factory='featuredb.lib.request.CommunityManagerRequest',
		authentication_policy=authn_policy,
		authorization_policy=authz_policy
	)

	config.include('pyramid_redis_sessions')

	config.add_route('enhancement', 'enhancement/{id:\d+}')
	config.add_route('enhancementupdate', 'enhancement/{action}')

	config.add_route('search_index', '/')

	config.add_route('search_results', 'results')

	config.add_route('report', 'report')
	config.add_route('suggestions', 'suggestions')
	config.add_route('suggestion_delete', 'suggestions/delete')
	config.add_route('concerns', 'concerns')

	# config.add_route('priority', 'priority')

	config.add_route('login', 'login')
	config.add_route('logout', 'logout')
	config.add_route('pwreset', 'pwreset')

	config.add_route('register', 'register')
	config.add_route('priority', 'priority')
	config.add_route('suggest', 'suggest')
	config.add_route('account', 'account')

	config.add_static_view('static', 'featuredb:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)
	config.add_static_view('/', 'featuredb:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)

	config.scan()

	return config.make_wsgi_app()
