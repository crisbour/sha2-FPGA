import struct
from collections import deque

class Sha:
    _k= (
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc,
    0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
    0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2,
    0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
    0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
    0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4,
    0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
    0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df,
    0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30,
    0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
    0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8,
    0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
    0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
    0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178,
    0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
    0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c,
    0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817)

    _h_224 = (0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
            0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4)
    _h_256 = (0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
            0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19)

    _h_384 = (0xcbbb9d5dc1059ed8, 0x629a292a367cd507, 0x9159015a3070dd17, 0x152fecd8f70e5939,
            0x67332667ffc00b31, 0x8eb44a8768581511, 0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4)

    _h_512 = (0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
            0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179)

    _sha_name = ('sha224', 'sha256', 'sha384', 'sha512')

    _output_words = [7,8,6,8]   # no. words
    _word_length = [4,4,8,8]    # bytes
    _max_word_length = 8        # bytes
    _max_output_words = 8       # no. words

    _wt_length = [4, 8]         # measured in bytes, bits: 32 and 64 respectively
    _wt_num = [64, 80]          # Number of Wt words per block

    _par_k = [[2, 13, 22], [28, 34, 39]]
    _par_g = [[6, 11, 25], [14, 18, 41]]
    _par_j = [[10, 19, 17], [6, 61, 19]]
    _par_l = [[3, 18, 7], [7, 8, 1]]

    @classmethod
    def resolve_name(self,sha_type):
        return self._sha_name[sha_type]

    @staticmethod
    def iters(sha_type):
        return 80 if (sha_type & 0x2) else 64

    @staticmethod
    def word_bytes(sha_type):
        return 8 if (sha_type & 0x2) else 4
    
    @classmethod
    def hash0(self, sha_type):
        h_init = (self._h_224, self._h_256, self._h_384, self._h_512)
        return h_init[sha_type]
    
    def __init__(self, sha_type):
        self.type = sha_type
        self.hash = [hi for hi in self.hash0(self.type)]
        self.regs = self.hash[:]
        self.windex = 0
        self.wlength = 80 if (sha_type & 0x2) else 64
        self.bits = self.word_bytes(self.type) * 8
        self.mod_mask = (1<<self.bits) - 1
        self.par_k = self._par_k[self.type>>1]
        self.par_g = self._par_g[self.type>>1]
        self.par_j = self._par_j[self.type>>1]
        self.par_l = self._par_l[self.type>>1]
        self.wt_len = self._wt_length[self.type>>1]
        self.wt_num = self._wt_num[self.type>>1]

    def _rotr(self, word, rsh):
        return ((word >> rsh) | (word<<(self.bits-rsh))) & self.mod_mask
    def _sigma0(self, word):    # Define for sha256
        return self._rotr(word, self.par_l[2]) ^ self._rotr(word, self.par_l[1]) ^ (word >> self.par_l[0])
    def _sigma1(self, word):    # Define for sha256
        return self._rotr(word, self.par_j[2]) ^ self._rotr(word, self.par_j[1]) ^ (word >> self.par_j[0])

    def _masked_k(self):
        if not (self.type>>1):
            shift = self.bits
            mask = 0xFFFFFFFF00000000
            return (self._k[self.windex] & mask) >> shift
        return self._k[self.windex]
    
    def padder(self, message):
        if isinstance(message, str):
            message = bytearray(message, 'ascii')
        elif isinstance(message, bytes):
            message = bytearray(message)
        elif not isinstance(message, bytearray):
            raise TypeError
        length = len(message)*8
        message += b'\x80'
        if self.type>>1:
            length_bytes = 16
        else:
            length_bytes = 8

        while((len(message) + length_bytes)%(64+64*(self.type>>1)) !=0 ):
            message += b'\x00'

        if self.type>>1:    # Assume that length_high fir SHA384/512 is always 0
            message += 8*b'\x00'
        
        length_mess = struct.pack('!Q', length) #length.to_bytes(8, 'big')
        self.message = message = message + length_mess
        # assert len(message)%(64+64*(self.type>>1) == 0, 'Message not padded correctly'
        return message

    def wt_transaction(self, message=None):

        if message == None:
            message = self.message[:]

        wt_total_transaction = b''
        w = deque()
        while len(message):
            for t in range(self.wt_num):
                if t<16:
                    # print(f'self.wt_len={self.wt_len}')
                    wt_temp, = struct.unpack('!Q',(8-self.wt_len)*b'\x00'+message[self.wt_len * t : self.wt_len * (t+1)])
                    w.append(wt_temp)
                    # self.update(wt_temp)
                    wt_total_transaction += struct.pack('!Q',wt_temp)
                else:
                    sigma0 = self._sigma0(w[1])
                    sigma1 = self._sigma1(w[14])
                    wt_temp = (w[0] + sigma0 + w[9] + sigma1) & self.mod_mask
                    # self.update(wt_temp)
                    w.append(wt_temp)
                    w.popleft()
                    wt_total_transaction += struct.pack('!Q',w[-1])
            w = deque()
            message = message[16*self.wt_len:]
        return wt_total_transaction


    def _sha256_process(self, word):
            a,b,c,d,e,f,g,h = self.regs
            s0 = self._rotr(a, self.par_k[0]) ^ self._rotr(a, self.par_k[1]) ^ self._rotr(a, self.par_k[2])
            maj = (a & b) ^ (a & c) ^ (b & c)
            t2 = s0 + maj
            s1 = self._rotr(e, self.par_g[0]) ^ self._rotr(e, self.par_g[1]) ^ self._rotr(e, self.par_g[2])
            ch = (e & f) ^ ((~e) & g)
            t1 = h + s1 + ch + self._masked_k() + word

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
        self._sha256_process(word)
        self.windex = self.windex + 1
        if self.windex == self.wlength:
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
            for i in range(self._output_words[self.type]):
                word_bytes = to_digest[i*self._max_word_length:(i+1)*self._max_output_words]
                word, = struct.unpack('!Q',word_bytes)
                word = word & self.mod_mask
                if self.type&0x2:
                    digest = digest + struct.pack('!Q',word)
                else:
                    digest = digest + struct.pack('!I',word)
        else:
            for i in range(self._output_words[self.type]):
                word = self.get_hash()
                if self.type&0x2:
                    digest = digest + struct.pack('!Q',word)
                else:
                    digest = digest + struct.pack('!I',word)
        return digest

