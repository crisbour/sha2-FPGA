from generate_message import *

my_message = Message()

print(my_message.Generate()+'\n')
print('Length of the message is {} characters = {} bits'.format(len(my_message.message),8*len(my_message.message)))

def print_pack():
	(tdata, tkeep, tlast) = my_message.AXIS_Message()
	print([hex(td) for td in tdata])
	print([hex(tk) for tk in tkeep])
	print(tlast)

def print_indv():
	tlast = 0
	while not tlast:
		tdata, tkeep, tlast = my_message.NextBlock()
		print((hex(tdata), hex(tkeep), tlast))
		print('\n')

print_pack()

bytestr = my_message.ByteStr()
print(bytestr)
