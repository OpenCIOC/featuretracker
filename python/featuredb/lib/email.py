# =========================================================================================
#  Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

# stdlib
import logging
import os
import textwrap

# 3rd party
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
		markup = Markup(
			'''\
			<p>Sending Email...<br><br>
			<strong>From:</strong> %s<br><br>
			<strong>To:</strong> %s<br><br>
			<strong>Reply-To:</strong> %s<br><br>
			<strong>Subject:</strong> %s<br><br>
			<strong>Message:</strong><br>%s</p>'''
		) % (
			message.author, ', '.join(unicode(x) for x in message.to), message.reply or '',
			message.subject, escape_silent(message.plain)
			.replace('\n', Markup('<br>'))
			.replace('\r', '')
		)
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
			'password': os.environ.get('CIOC_MAIL_PASSWORD'),
			'port': os.environ.get('CIOC_MAIL_PORT'),
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
		host = os.environ.get('CIOC_MAIL_HOST', '127.0.0.1')
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


def format_message(message, sep='\n\n'):
	return sep.join(textwrap.fill(x, width=80) for x in message.split(sep))
