import os

from featuredb import config, connection

from pyramid.httpexceptions import HTTPFound
from pyramid.config import Configurator
from pyramid_beaker import session_factory_from_settings

import logging
log = logging.getLogger('featuredb.__init__')

app_path = None
config_file = None
app_name = None

def on_new_request(event):
	global app_path, config_file, app_name
	request = event.request

	if app_path is None:
		app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..'))
		app_name = os.path.split(app_path)[1]
		config_file = os.path.join(app_path, '..', '..', 'config', app_name + '.ini')

	request.config = config.get_config(config_file)
	request.connmgr = connection.ConnectionManager(request, request.config)
	
	request.user = request.session.get('user')

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
	session_factory = session_factory_from_settings(settings)
	config = Configurator(settings=settings, session_factory=session_factory)

	config.add_route('enhancement', '/enhancement/{id:\d+}')

	config.add_handler('search_index', '/',
			handler='featuredb.views.search.Search', action='index')

	config.add_handler('search_results', 'results',
			handler='featuredb.views.search.Search', action='results')

	#config.add_route('priority', 'priority')

	config.add_route('login', 'login')
	config.add_route('logout', 'logout')

	config.add_route('register', 'register')
	config.add_route('priority', 'priority')

	config.add_static_view('static', 'featuredb:static', cache_max_age=3600)
	config.add_static_view('/', 'featuredb:static', cache_max_age=3600)


	config.add_subscriber(on_new_request, 'pyramid.events.NewRequest')
	config.add_subscriber(on_context_found, 'pyramid.events.ContextFound')
	config.scan()

	return config.make_wsgi_app()

