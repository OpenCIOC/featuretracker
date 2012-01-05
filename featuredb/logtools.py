import os
import logging.handlers

_app_name = None

def _get_app_name():
	global _app_name
	if _app_name is None:
		app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..'))
		_app_name = os.path.split(app_path)[1]

	return _app_name

_log_root = None
class TimedRotatingFileHandler(logging.handlers.TimedRotatingFileHandler):
	def __init__(self, name):
		global _log_root

		app_name = _get_app_name()

		if _log_root is None:
			_log_root = os.environ.get('CIOC_LOG_ROOT', 'd:\log')

		logfile = os.path.join(_log_root, app_name, 'python', name)

		logging.handlers.TimedRotatingFileHandler.__init__(self, logfile, 'midnight', delay=True)


_server = None
class SMTPHandler(logging.handlers.SMTPHandler):
	def __init__(self, server, fromaddr, toaddrs, subject, credentials=None, secure=None):
		global _server
		if server is None:
			if _server is None:
				_server = os.environ.get('CIOC_MAILHOST', 'mail.oakville.ca')
			server = _server
		
		app_name = _get_app_name()

		subject = subject.format(site_name=app_name)

		logging.handlers.SMTPHandler.__init__(self, server, fromaddr, toaddrs, subject, credentials, secure)

