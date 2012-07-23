#stdlib
import logging


#3rd party
from pyramid.httpexceptions import HTTPFound
from pyramid.config import Configurator
from pyramid.decorator import reify
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import NO_PERMISSION_REQUIRED, Authenticated, Everyone, Allow, DENY_ALL

from pyramid_beaker import session_factory_from_settings


#this app
from featuredb.lib import const

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

def on_context_found(event):
	request = event.request

	if request.user:
		return

	if not request.matched_route or request.matched_route.name in {'login', 'register'} or \
		request.matched_route.name.startswith('debugtoolbar.') or \
		request.matched_route.name.startswith('__'):
		# always available
		return

	if request.params.get('bypass_login'):
		request.session['bypass_login'] = True
		return

	if request.session.get('bypass_login'):
		return

	raise HTTPFound(location=request.route_url('login'))


def main(global_config, **settings):
	""" This function returns a Pyramid WSGI application.
	"""

	const.update_cache_values()
	session_factory = session_factory_from_settings(settings)

	authn_policy = SessionAuthenticationPolicy(callback=groupfinder, debug=True)
	authz_policy = ACLAuthorizationPolicy()

	config = Configurator(settings=settings, session_factory=session_factory,
						  root_factory=RootFactory,
						default_permission='public',
						  request_factory='featuredb.lib.request.CommunityManagerRequest',
						 authentication_policy=authn_policy,
						 authorization_policy=authz_policy)

	config.add_route('enhancement', 'enhancement/{id:\d+}')
	config.add_route('enhancementupdate', 'enhancement/{action}')
	
	config.add_route('search_index', '/')

	config.add_route('search_results', 'results')

	config.add_route('report', 'report')
	config.add_route('suggestions', 'suggestions')
	config.add_route('concerns', 'concerns')

	#config.add_route('priority', 'priority')

	config.add_route('login', 'login')
	config.add_route('logout', 'logout')

	config.add_route('register', 'register')
	config.add_route('priority', 'priority')
	config.add_route('suggest', 'suggest')
	config.add_route('account', 'account')

	config.add_static_view('static', 'featuredb:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)
	config.add_static_view('/', 'featuredb:static', cache_max_age=3600, permission=NO_PERMISSION_REQUIRED)

	config.scan()

	return config.make_wsgi_app()

