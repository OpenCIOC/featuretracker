# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================
#stdlib
import os


import logging

#3rd party
from markupsafe import Markup, escape_silent
from marrow.mailer import Mailer, Message
from marrow.mailer.exc import DeliveryException

DeliveryException

log = logging.getLogger(__name__)

_mailer = None


class DummyMailer(object):
	def __init__(self, request):
		self.request = request

	def send(self, message):
		markup = Markup('''\
					<p>Sending Email...<br><br>
					<strong>From:</strong> %s<br><br>
					<strong>To:</strong> %s<br><br>
					<strong>Reply-To:</strong> %s<br><br>
					<strong>Subject:</strong> %s<br><br>
					<strong>Message:</strong><br>%s</p>''') % (
						message.author, ', '.join(unicode(x) for x in message.to), message.reply or '',
						message.subject, escape_silent(message.plain)
						.replace('\n', Markup('<br>'))
						.replace('\r', ''))
		log.debug('Sending email %s', markup)
		self.request.session.flash(markup, 'email_messages')


class DummyMailerFactory(object):
	def __call__(self, request):
		return DummyMailer(request)


class RealMailerFactory(object):
	def __init__(self, host):
		transport = {
			'use': 'smtp',
			'host': host,
			'username': os.environ.get('CIOC_MAIL_USERNAME'),
			'password': os.environ.get('CIOC_MAIL_PASSWORD')
		}

		log.debug('transport host: %s', host)

		transport = {k: v for k, v in transport.iteritems() if v}
		mailer = self.mailer = Mailer({
			'transport': transport,
			'manager': {'use': 'immediate'}
		})
		mailer.start()

	def __call__(self, request):
		return self.mailer

_mailer_factory = None


def _get_mailer(request):
	global _mailer_factory

	if not _mailer_factory:
		host = os.environ.get('CIOC_MAIL_HOST', '192.168.100.20')
		if host == 'test':
			_mailer_factory = DummyMailerFactory()

		else:
			_mailer_factory = RealMailerFactory(host)

	return _mailer_factory(request)


def send_email(request, author, to, subject, message, reply=None):
	if not isinstance(to, (list, tuple)):
		to = [to]

	to = [unicode(x) for x in to if x]

	mailer = _get_mailer(request)
	args = dict(author=unicode(author), to=to, subject=subject, plain=message)
	if reply:
		args['reply'] = unicode(reply)
	message = Message(**args)
	mailer.send(message)
