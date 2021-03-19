import struct
from collections import deque
import yaml
import os
import sys

class Sha2:

    def extract_config(self, filename):
        with open(os.path.join(os.path.dirname(__file__), filename),'r') as file:
            yaml_dict = yaml.load(file, Loader=yaml.FullLoader)
            config = yaml_dict['sha_hashing'][self.sha_name]
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
            self.par_k = config['HashCompute']['parameters']['k']
            self.par_g = config['HashCompute']['parameters']['g']
            self.par_j = config['Wt']['parameters']['j']
            self.par_l = config['Wt']['parameters']['l']
            self.hash0 = config['HashCompute']['InitHash']
            kt = config['HashCompute']['Kt']['value']
            kt_reps = config['HashCompute']['Kt']['repetitions']
            self.kt = [val for val in kt for _ in range(kt_reps)]
            self.output_size = config['HashCompute']['FinalHash']['output_size']

    def restart(self):
        self.regs = self.hash = self.hash0[:]
        self.windex = 0
    
    def __init__(self, sha_name=None):
        self.sha_name = sha_name
        self.extract_config("hash_config.yaml")
        self.wt_size_bits = 8 * self.word_size
        self.mod_mask = (1<<self.wt_size_bits) - 1
        self.restart()

    def _rotr(self, word, rsh):
        return ((word >> rsh) | (word<<(self.wt_size_bits-rsh))) & self.mod_mask
    def _sigma0(self, word):    # Define for sha256
        return self._rotr(word, self.par_l[2]) ^ self._rotr(word, self.par_l[1]) ^ (word >> self.par_l[0])
    def _sigma1(self, word):    # Define for sha256
        return self._rotr(word, self.par_j[2]) ^ self._rotr(word, self.par_j[1]) ^ (word >> self.par_j[0])
    
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

        # Assume that length_high fir SHA384/512 is always 0
        message += (self.length_size - 8) * b'\x00'
        
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
                    wt_total_transaction += struct.pack('!Q',wt_temp)
                else:
                    sigma0 = self._sigma0(w[1])
                    sigma1 = self._sigma1(w[14])
                    wt_temp = (w[0] + sigma0 + w[9] + sigma1) & self.mod_mask
                    self.update(wt_temp)
                    w.append(wt_temp)
                    w.popleft()
                    wt_total_transaction += struct.pack('!Q',w[-1])
            w = deque()
            message = message[16*self.word_size:]
        return wt_total_transaction


    def _sha2_process(self, word):
            a,b,c,d,e,f,g,h = self.regs
            s0 = self._rotr(a, self.par_k[0]) ^ self._rotr(a, self.par_k[1]) ^ self._rotr(a, self.par_k[2])
            maj = (a & b) ^ (a & c) ^ (b & c)
            t2 = s0 + maj
            s1 = self._rotr(e, self.par_g[0]) ^ self._rotr(e, self.par_g[1]) ^ self._rotr(e, self.par_g[2])
            ch = (e & f) ^ ((~e) & g)
            t1 = h + s1 + ch + self.kt[self.windex] + word

            h = g
            g = f
            f = e
            e = (d + t1) & self.mod_mask
            d = c
            c = b
            b = a
            a = (t1 + t2) & self.mod_mask
            
            self.regs = [a,b,c,d,e,f,g,h]    

    def update(self, word):
        if self.windex == 0:
            self.regs = self.hash[:]
        self._sha2_process(word)
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
            buffer = buffer + struct.pack('!Q',h)
        return buffer

    def digest(self, to_digest=None):
        digest = b''
        if to_digest:
            for i in range(self.output_size):
                word_bytes = to_digest[i*self._max_word_length:(i+1)*self._max_output_words]
                word, = struct.unpack('!Q',word_bytes)
                word = word & self.mod_mask
                if self.word_size == 8:
                    digest = digest + struct.pack('!Q',word)
                else:
                    digest = digest + struct.pack('!I',word)
        else:
            for i in range(self.output_size):
                word = self.hash[i]
                if self.word_size == 8:
                    digest = digest + struct.pack('!Q',word)
                else:
                    digest = digest + struct.pack('!I',word)
        return digest

