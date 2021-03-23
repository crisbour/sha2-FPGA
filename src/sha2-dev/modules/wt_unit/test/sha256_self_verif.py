import struct
from cocotb.utils import hexdump

class SHA256:
    bool_pad = False
    _k = (0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
          0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
          0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
          0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
          0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
          0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
          0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
          0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
          0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
          0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
          0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
          0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
          0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
          0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
          0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
          0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2)
    _h = (0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
          0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19)
    _output_size = 8

    def __init__(self, message=None):
        self._buffer = ''
        self._counter = 0
        self.block_index = 0
        self.M = message
        self.words =[]

    def _rotr(self, word, rsh):
        return ((word >> rsh) | (word<<(32-rsh))) & 0xFFFFFFFF
    def _sigma0(self, word):
        return self._rotr(word, 7) ^ self._rotr(word, 18) ^ (word >> 3)
    def _sigma1(self, word):
        return self._rotr(word, 17) ^ self._rotr(word, 19) ^ (word >> 10)
        
    def padding(self):
        if not self.bool_pad:
            self._counter = len(self.M)
            padlen = (64 - (self._counter + 1) % 64) - 8
            if padlen<0:
                padlen += 64
            self.M =self.M + b'\x80' + padlen*b'\x00' + struct.pack('!Q', self._counter<<3)
        return self.M

    def NextWords(self):
        if(self.block_index*64 < len(self.M)):
            w = [0]*64
            w[0:16] = struct.unpack('!16L', self.M[64*self.block_index:64*(self.block_index+1)])
            self.block_index += 1

            for i in range(16, 64):
                s0 = self._rotr(w[i-15], 7) ^ self._rotr(w[i-15], 18) ^ (w[i-15] >> 3)
                s1 = self._rotr(w[i-2], 17) ^ self._rotr(w[i-2], 19) ^ (w[i-2] >> 10)
                w[i] = (w[i-16] + s0 + w[i-7] + s1) & 0xFFFFFFFF

            for w_val in w:
                self.words.append(w_val)
        else:
            w = []
        return w

    def _sha256_process(self):
        while self.words:
            w = self.words[:64]
            self.words = self.words[64:]

            a,b,c,d,e,f,g,h = self._h
            for i in range(64):
                s0 = self._rotr(a, 2) ^ self._rotr(a, 13) ^ self._rotr(a, 22)
                maj = (a & b) ^ (a & c) ^ (b & c)
                t2 = s0 + maj
                s1 = self._rotr(e, 6) ^ self._rotr(e, 11) ^ self._rotr(e, 25)
                ch = (e & f) ^ ((~e) & g)
                t1 = h + s1 + ch + self._k[i] + w[i]
                
                h = g
                g = f
                f = e
                e = (d + t1) & 0xFFFFFFFF
                d = c
                c = b
                b = a
                a = (t1 + t2) & 0xFFFFFFFF
                
            self._h = [(x+y) & 0xFFFFFFFF for x,y in zip(self._h, [a,b,c,d,e,f,g,h])]
    
    def digest(self):
        return b''.join([struct.pack('!L', i) for i in self._h[:self._output_size]])

    def hexdigest(self):
        return self.digest().hex()

    def compute(self):
        w = True
        while w:
            w = self.NextWords()
        self._sha256_process()




mess = b'8U\xa3@\x9a\xb3\x94\xd2\xcb\x9a5\xa3\xd7\xba\x00\x87\xc2py\xc8\xb1M\xa5M\xb6\x94f#\xfc4\xe0\x12.\x8ey\xc6;8\x8dz|\x80\xb5\n\xcc\xb8.\xe1\x88\x08u/H\xdb9\xd1\xaen\x01QC\x91\x9b\xbd\xf1m\x9b\x8a\xb4gL\xb1+p\xd1"\x9f\x86\x9c\x92\xbb\xfb\xc7\xee\xce\xc8\xc1m\xf1\xb3\x9f\xc7\xd8\xe1\xfb\xca\x991\xae<\xda\xbf!9\x8bk(\xdb}\x82\xbb\x92}z3.\x1et\xbaC\xdd|\x91COpu\xc9'
print(mess[0:64])
sha2 = SHA256(mess)
#print(sha2.padding())
eom = False
while not eom:
    w_bytes = b''.join([struct.pack('!L', w) for w in sha2.NextWords()])
    if w_bytes!=b'':
        print(hexdump(w_bytes))
    else:
        eom = True
# print([struct.pack('!L', w) for w in sha2.NextWords()])
sha2.compute()
print(sha2.hexdigest())
#print([struct.pack('!Q', w) for w in sha2.NextWords()])