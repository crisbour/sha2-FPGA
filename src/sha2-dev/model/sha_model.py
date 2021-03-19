import struct
from collections import deque
from sha1 import Sha1
from sha2 import Sha2

def get_sha_method(codec=None, sha_name=None):
    _codecs_name = {0x11:'sha1', 0x12:'sha256', 0x13:'sha512', 0x09:'sha224', 0x10:'sha384'}
    sha2_variants = ['sha224', 'sha256', 'sha384', 'sha512']

    assert codec or sha_name
    if(codec):
        if codec in _codecs_name:
            sha_name = _codecs_name[codec]
    assert sha_name != None
    
    if sha_name == 'sha1':
        return Sha1()
    elif sha_name in sha2_variants:
        return Sha2(sha_name=sha_name)
    else:
        raise ValueError(f'{sha_name} not supported. Only sha1 and sha2 are supported.')

