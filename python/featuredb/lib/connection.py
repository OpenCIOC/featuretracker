# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

import pyodbc


class ConnectionManager(object):
	def __init__(self, request):
		self.request = request
		self.config = request.config

	def get_connection_string(self):
		config = self.config
		settings = [
			('Driver', '{%s}' % config.get('driver', 'SQL Server Native Client 10.0')),
			('Server', config['server']),
			('Database', config['database']),
			('UID', config['uid']),
			('PWD', config['pwd'])
		]

		return ';'.join('='.join(x) for x in settings)

	def get_connection(self):
		conn = pyodbc.connect(self.get_connection_string(), autocommit=True, unicode_results=True)

		return conn
