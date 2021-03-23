import struct
from collections import deque
from sha1 import Sha1
from sha2 import Sha2

class Sha:
    _codecs_name = {0x11:'sha1', 0x12:'sha256', 0x13:'sha512', 0x09:'sha224', 0x10:'sha384'}
    sha_dict = {'sha1':['sha1'], 'sha2':['sha224','sha256','sha384','sha512']}

    @classmethod
    def resolve_class(cls, codec=None, sha_name=None):
        assert codec or sha_name

        if(codec):
            if codec in cls._codecs_name:
                sha_name = cls._codecs_name[codec]
        assert sha_name != None
        
        if sha_name in cls.sha_dict['sha1']:
            return Sha1
        elif sha_name in cls.sha_dict['sha2']:
            return Sha2
        else:
            raise ValueError(f'{sha_name} not supported. Only sha1 and sha2 are supported.')
    
    @classmethod
    def resolve_name(cls, codec=None, sha_name=None):
        assert codec or sha_name

        if(codec):
            if codec in cls._codecs_name:
                sha_name = cls._codecs_name[codec]
        assert sha_name != None
        
        if sha_name in cls.sha_dict['sha1']:
            return sha_name
        elif sha_name in cls.sha_dict['sha2']:
            return sha_name
        else:
            raise ValueError(f'{sha_name} not supported. Only sha1 and sha2 are supported.')
    
    @staticmethod
    def blocks512(codec):
        sha_class = Sha.resolve_class(codec=codec)
        sha_name = Sha.resolve_name(codec=codec)
        return int(sha_class(sha_name).block_size/64)

    @classmethod
    def get_method(cls, codec=None, sha_name=None):
        sha_class = cls.resolve_class(codec=codec, sha_name=sha_name)
        sha_name = cls.resolve_name(codec=codec, sha_name=sha_name)

        return sha_class(sha_name)

    

