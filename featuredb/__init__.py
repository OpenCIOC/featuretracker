from pyramid.config import Configurator
from pyramid_beaker import session_factory_from_settings

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    session_factory = session_factory_from_settings(settings)
    config = Configurator(settings=settings, session_factory=session_factory)

    config.add_static_view('static', 'featuredb:static', cache_max_age=3600)
    config.add_static_view('favicon.ico', 'featuredb:static/favicon.ico', cache_max_age=3600)
    config.add_static_view('robots.txt', 'featuredb:static/robots.txt', cache_max_age=3600)
    config.add_static_view('humans.txt', 'featuredb:static/humans.txt', cache_max_age=3600)

    config.add_handler('home_index', '/',
            handler='featuredb.views.Index', action='index')

    config.add_handler('home', '/{action}',
            handler='featuredb.views.Index')

    return config.make_wsgi_app()

