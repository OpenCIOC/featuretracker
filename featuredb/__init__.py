import os

from featuredb import config, connection

from pyramid.config import Configurator
from pyramid_beaker import session_factory_from_settings

app_path = None
config_file = None
app_name = None

def on_new_request(event):
	global app_path, config_file, app_name
	request = event.request

	#renderer = get_renderer('cioc.web:templates/master.mak')
	
	#set_template_lookup(request.registry.queryUtility(IMakoLookup))

	if app_path is None:
		app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..'))
		app_name = os.path.split(app_path)[1]
		config_file = os.path.join(app_path, '..', '..', 'config', app_name + '.ini')

	request.config = config.get_config(config_file)
	request.connmgr = connection.ConnectionManager(request, request.config)


def main(global_config, **settings):
	""" This function returns a Pyramid WSGI application.
	"""
	session_factory = session_factory_from_settings(settings)
	config = Configurator(settings=settings, session_factory=session_factory)

	config.add_static_view('static', 'featuredb:static', cache_max_age=3600)
	config.add_static_view('favicon.ico', 'featuredb:static/favicon.ico', cache_max_age=3600)
	config.add_static_view('robots.txt', 'featuredb:static/robots.txt', cache_max_age=3600)
	config.add_static_view('humans.txt', 'featuredb:static/humans.txt', cache_max_age=3600)

	config.add_route('enhancement', '/enhancement/{id:\d+}')

	config.add_handler('search_index', '/',
			handler='featuredb.views.search.Search', action='index')

	config.add_handler('search_results', '/results',
			handler='featuredb.views.search.Search', action='results')

	config.add_handler('priority', '/priority',
			handler='featuredb.views.priority.Priority', action='index')

	config.add_handler('login', '/login',
			handler='featuredb.views.login.Login', action='index')

	config.add_handler('register', '/register',
			handler='featuredb.views.register.Register', action='index')


	config.add_subscriber(on_new_request, 'pyramid.events.NewRequest')
	config.scan()

	return config.make_wsgi_app()

