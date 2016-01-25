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

import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
	'pyramid',
	'pyramid_beaker',
	'pyramid_debugtoolbar',
	]

setup(
	name='FeatureDb',
	version='0.0',
	description='FeatureDb',
	long_description=README + '\n\n' + CHANGES,
	classifiers=[
		"Programming Language :: Python",
		"Framework :: Pylons",
		"Topic :: Internet :: WWW/HTTP",
		"Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
	],
	author='',
	author_email='',
	url='',
	keywords='web wsgi bfg pylons pyramid',
	packages=find_packages(),
	include_package_data=True,
	zip_safe=False,
	install_requires=requires,
	entry_points="""\
	[paste.app_factory]
	main = featuredb:main
	""",
	paster_plugins=['pyramid'],
)
