from beaker.crypto.pbkdf2 import PBKDF2
from Crypto.Random import get_random_bytes

DEFAULT_REPEAT = 4096
def Crypt(salt, password, repeat=DEFAULT_REPEAT):
	pbkdf2 = PBKDF2(password, salt, int(repeat))
	return pbkdf2.read(33).encode('base64').strip()

def MakeSalt():
	return get_random_bytes(33).encode('base64').strip()

