import struct
from collections import deque
import yaml
import os

class Sha1:
    _config_filename = "hash_config.yaml"

    def extract_config(self, sha_name):
        with open(os.path.join(os.path.dirname(__file__), self._config_filename),'r') as file:
            yaml_dict = yaml.load(file, Loader=yaml.FullLoader)
            config = yaml_dict['sha_hashing'][sha_name]
            counter_type = config['counter_type']
            if(counter_type == 'bytes'):
                prescaler = 1
            elif(counter_type == 'bits'):
                prescaler = 8
            else:
                raise ValueError(f'"counter_type" is neither bytes or bits. Check the configuration file at the element {sha_name}')
            self.word_size = int(config['word_size']/prescaler)
            self.length_size = int(config['Padder']['length_size']/prescaler)
            self.block_size = int(config['Padder']['block_size']/prescaler)
            self.wt_iters = config['Wt']['iters']
            self.hash0 = config['HashCompute']['InitHash']
            kt = config['HashCompute']['Kt']['value']
            kt_reps = config['HashCompute']['Kt']['repetitions']
            self.kt = [val for val in kt for _ in range(kt_reps)]
            self.output_size = config['HashCompute']['FinalHash']['output_size']

    def init(self):
        self.regs = self.hash = self.hash0[:]
        self.windex = 0
    
    def __init__(self, sha_name='sha1'):
        self.sha_name = sha_name
        assert self.sha_name == 'sha1', f'Expected sha_name = sha1, but received {sha_name}'
        self.extract_config(self.sha_name)
        self.wt_size_bits = 8 * self.word_size
        self.mod_mask = (1<<self.wt_size_bits) - 1
        self.init()

    def _rotl(self, word, lsh):
        return ((word << lsh) | (word>>(self.wt_size_bits-lsh))) & self.mod_mask
    def _wt_func(self,w):
        return self._rotl(w[16-3]^w[16-8]^w[16-14]^w[16-16],1)

    def padder(self, message):
        if isinstance(message, str):
            message = bytearray(message, 'ascii')
        elif isinstance(message, bytes):
            message = bytearray(message)
        elif not isinstance(message, bytearray):
            raise TypeError
        length = len(message)*8
        message += b'\x80'

        while((len(message) + self.length_size)%(self.block_size) !=0 ):
            message += b'\x00'

        
        length_mess = struct.pack('!Q', length) #length.to_bytes(8, 'big')
        self.message = message + length_mess
        # assert len(message)%(64+64*(self.type>>1) == 0, 'Message not padded correctly'
        return bytes(self.message)

    def wt_transaction(self, message=None):

        if message == None:
            message = self.message[:]

        wt_total_transaction = b''
        w = deque()
        while len(message):
            for t in range(self.wt_iters):
                if t<16:
                    # print(f'self.wt_len={self.wt_len}')
                    wt_temp, = struct.unpack('!Q',(8-self.word_size)*b'\x00'+message[self.word_size * t : self.word_size * (t+1)])
                    w.append(wt_temp)
                    self.update(wt_temp)
                    wt_total_transaction += struct.pack('!I',wt_temp)
                else:
                    wt_temp = self._wt_func(w)
                    self.update(wt_temp)
                    w.append(wt_temp)
                    w.popleft()
                    wt_total_transaction += struct.pack('!I',wt_temp)
            w = deque()
            message = message[16*self.word_size:]
        return wt_total_transaction

    def _sha1_process_func(self,t,b,c,d):
        if(0 <= t <= 19):
            return d ^ (b & (c ^ d))
        elif(20 <= t <= 39):
            return b ^ c ^ d
        elif(40 <= t <= 59):
            return (b & c) | (b & d) | (c & d)
        elif(60 <= t <= 79):
            return b ^ c ^ d
        else:
            raise ValueError(f'"t" has to be in the interval [0,79]. t = {t}')

    def _sha1_process(self, word):
            a,b,c,d,e = self.regs
            t = self.windex
            temp = self._rotl(a, 5) + self._sha1_process_func(t,b,c,d) + e + word + self.kt[t]

            e = d
            d = c
            c = self._rotl(b,30)
            b = a
            a = temp & self.mod_mask
            
            self.regs = [a,b,c,d,e]    

    def update(self, word):
        if self.windex == 0:
            self.regs = self.hash[:]
        self._sha1_process(word)
        self.windex = self.windex + 1
        if self.windex == self.wt_iters:
            self.windex = 0
            self.hash = [(x+y) & self.mod_mask for x,y in zip(self.hash, self.regs)]

    def get_regs(self):
        return self.regs

    def get_hash(self):
        return self.hash
    
    def get_bytes_hash(self):
        buffer = b''
        for h in self.hash:
            buffer = buffer + struct.pack('!I',h)
        return buffer

    def digest(self, to_digest=None):
        digest = b''
        if to_digest:
            for i in range(self.output_size):
                word_bytes = to_digest[i*self._max_word_length:(i+1)*self._max_output_words]
                word, = struct.unpack('!I',word_bytes)
                word = word & self.mod_mask
                digest = digest + struct.pack('!I',word)
        else:
            for i in range(self.output_size):
                word = self.hash[i]
                digest = digest + struct.pack('!I',word)
        return digest

