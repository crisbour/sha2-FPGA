import string
import random
import codecs

class Message:
	def __init__(self,max_length=300,bit_width=512):
		self.maxL = max_length
		self.bit_width = bit_width
		self.message = None
		self.next_block_index = 0
		self.Generate()

	def Generate(self):
		length = random.randint(0,self.maxL)
		characters = string.ascii_letters + string.digits + string.punctuation
		self.message = ''.join(random.choice(characters) for i in range(length))
		self.next_block_index = 0
		return self.message

	def NextBlock(self):
		# Bound what characters to extract for this block
		start = self.next_block_index * int(self.bit_width/8)
		stop = (self.next_block_index + 1) * int(self.bit_width/8) - 1
		if start >= len(self.message):
			return (0, 0 ,1)
		if stop >= len(self.message) - 1:
			tlast = 1
			stop = len(self.message) - 1
		else:
			tlast = 0
		
		# Crate tdata and tkeep from the added characters
		tdata = 0; tkeep = 0
		for i in range(start, stop + 1):
			offset = i - start
			tdata = tdata + (ord(self.message[i])<<(offset*8))
			tkeep = tkeep + (1 << offset)
		
		# Increment next block indentifier
		self.next_block_index += 1

		return (tdata, tkeep, tlast)

	def AXIS_Message(self):
		# Make list of all transmissions for the current message
		tdata = []
		tkeep = []
		tlast = []
		
		tl = 0
		while not tl:
			(td, tk, tl) = self.NextBlock()
			tdata.append(td)
			tkeep.append(tk)
			tlast.append(tl)
		
		self.next_block_index = 0
		return (tdata, tkeep, tlast)
	
	def ByteStr(self):
		bytestr = bytes(self.message,'utf-8')
		return bytestr