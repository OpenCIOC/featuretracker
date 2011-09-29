from formencode.validators import *

MAX_ID = 2147483647


class UnicodeString(UnicodeString):
	trim = True
	if_empty = None

class String(String):
	trim = True
	if_empty = None

class IntID(Int):
	if_empty = None
	min = 1
	max = MAX_ID

