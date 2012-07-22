import re

from formencode import validators, schema

MAX_ID = 2147483647

_ = lambda x: x

class UnicodeString(validators.UnicodeString):
	trim = True
	if_empty = None

class String(validators.String):
	trim = True
	if_empty = None

class IntID(validators.Int):
	if_empty = None
	min = 1
	max = MAX_ID

class Email(validators.Email):
	trim = True
	if_empty = None

	#update re from dev version of Formencode
	usernameRE = re.compile(r"^[\w!#$%&'*+\-/=?^`{|}~.]+$")
	domainRE = re.compile(r'''
		^(?:[a-z0-9][a-z0-9\-]{,62}\.)+ # (sub)domain - alpha followed by 62max chars (63 total)
		[a-z]{2,}$						 # TLD
	''', re.I | re.VERBOSE)

class AgencyCode(validators.Regex):
	strip = True
	regex = '^[A-Z][A-Z][A-Z]$'
	messages = {'invalid': _("Invalid Agency Code")}

from datetime import date, timedelta
class TomorrowsDate(validators.DateValidator):

	@property
	def earliest_date(self):
		return date.today() + timedelta(days=1)

	@property
	def latest_date(self):
		return date.today() + timedelta(days=1)

class ForceRequire(validators.FormValidator):
    """
    Forced fields to be required, even if they have a missing value
    ::

        >>> f = ForceRequire('pass', 'conf')
        >>> f.to_python({'pass': 'xx', 'conf': 'xx'})
        {'conf': 'xx', 'pass': 'xx'}
        >>> f.to_python({'conf': 'yy'})
        Traceback (most recent call last):
            ...
        Invalid: pass: Please enter a value
    """

    field_names = None
    validate_partial_form = True

    __unpackargs__ = ('*', 'field_names')

    def validate_partial(self, field_dict, state):
        self.validate_python(field_dict, state)

    def validate_python(self, field_dict, state):
        errors = {}
        for name in self._convert_to_list(self.field_names):
            if not field_dict.get(name):
                errors[name] = Invalid(self.message('empty', state), field_dict, state)

        if errors:
            raise Invalid(schema.format_compound_error(errors),
                            field_dict, state, error_dict=errors)

        return field_dict

    def _convert_to_list(self, value):
        if isinstance(value, (str, unicode)):
            return [value]
        elif value is None:
            return []
        elif isinstance(value, (list, tuple)):
            return value
        try:
            for n in value:
                break
            return value
        ## @@: Should this catch any other errors?:
        except TypeError:
            return [value]


DateConverter = validators.DateConverter
FieldsMatch = validators.FieldsMatch
MaxLength = validators.MaxLength
Int = validators.Int
Bool = validators.Bool
Invalid = validators.Invalid
