# Install python requirements
apt install -y python3 python3-pip python-setuptools git

# Install verilog compilers
apt install -y iverilog verilator

# Install cocotb and cocotbext requirements
COCOTB_LIB=/home/ubuntu/lib
su ubuntu <<EOSU
mkdir -p $COCOTB_LIB
cd $COCOTB_LIB
git clone https://github.com/cocotb/cocotb
git clone https://github.com/cristi-bourceanu/cocotbext-axis
pip3 install cocotb
pip3 install $COCOTB_LIB/cocotbext-axis/
EOSU