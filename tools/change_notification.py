# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
# ==================================================================

# stdlib
import argparse
from cStringIO import StringIO
import datetime
from itertools import groupby
from operator import attrgetter
import os
import sys
import traceback

sys.append(os.path.dirname(os.path.dirname(__file__)))

# 3rd party
from pyramid.paster import bootstrap
from pyramid.renderers import render
import isodate

# this app
from featuredb.lib import email, const, config, connection

const.update_cache_values()


def main(argv):
	args = parse_args(argv)
	retval = 0

	bootstrap(args.pyramid_config)
	try:
		args.config = config.get_config(args.configfile)
	except Exception:
		sys.stderr.write('ERROR: Could not process config file:\n')
		sys.stderr.write(traceback.format_exc())
		return 1

	args.connmgr = connection.ConnectionManager(args)

	changes = fetch_changes(args, args.since)
	for userinfo in group_users(args, changes):
		send_notification(args, userinfo)

	return retval


def mkdatetime(value):
	if 'T' in value:
		return isodate.parse_datetime(value)
	else:
		date = isodate.parse_date(value)
		return datetime.datetime(date.year, date.month, date.day)


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('pyramid_config', action='store')
	parser.add_argument('--url', action='store', help='base url for site', default='https://features.cioc.ca')
	parser.add_argument('--since', type=mkdatetime, default=datetime.datetime.now() - datetime.timedelta(days=1, minutes=5))

	return parser.parse_args(argv)


def fetch_changes(args, yesterday):
	with args.connmgr.get_connection() as conn:
		cursor = conn.execute('EXEC sp_User_l_EnhancementNotifications ?', yesterday)
		changes = cursor.fetchall()

	return changes


def group_users(args, changes):
	for (user, addr, firstname, onnew, onchange), group in groupby(changes, key=attrgetter('USER_ID', 'Email', 'FirstName', 'EmailOnNew', 'EmailOnUpdate')):
		namespace = {
			'USER_ID': user, 'Email': addr, 'FirstName': firstname,
			'created_enhancements': None, 'updated_enhancements': None,
			'BASEURL': args.url, 'since_date': args.since
		}

		if onnew and onchange:
			namespace['notification_type'] = 'an enhancement you have ranked is updated or a new one is added'
		elif onnew:
			namespace['notification_type'] = 'a new enhancement is added'
		else:
			namespace['notification_type'] = 'an enhancement you have ranked is updated'

		for add, enhancements in groupby(group, key=attrgetter('IsAdd')):
			if add:
				namespace['created_enhancements'] = list(enhancements)
			else:
				namespace['updated_enhancements'] = list(enhancements)

		yield namespace


def send_notification(args, namespace):
	body = render('featuredb:templates/email/notification.mak', namespace)
	subject = 'Updated Enhancements -- CIOC Feature Request DB'
	email.send_email(None, 'admin@cioc.ca', namespace['Email'], subject, email.format_message(body, sep="\n"))


class FileWriteDetector(object):

	def __init__(self, obj):
		self.__obj = obj
		self.__dirty = False

	def is_dirty(self):
		return self.__dirty

	def write(self, string):
		self.__dirty = True
		return self.__obj.write(string)

	def __getattr__(self, key):
		return getattr(self.__obj, key)


if __name__ == '__main__':
	if os.path.basename(sys.executable) == 'pythonw.exe':
		sys.stdout = StringIO()
		sys.stderr = FileWriteDetector(sys.stdout)

		def dumperroremail():
			if sys.stderr.is_ditry():
				email.send_email(None, 'qw4afPcItA5KJ18NH4nV@cioc.ca', ['qw4afPcItA5KJ18NH4nV@cioc.ca'],
						'Feature DB Notifications Output', sys.stdout.getvalue())

		import atexit
		atexit.register(dumperroremail)

	sys.exit(main(sys.argv[1:]))
