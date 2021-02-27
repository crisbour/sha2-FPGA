export BOARD_NAME=au280

export VERSION=2019.2

if [ ${BOARD_NAME} != "au280" -a \
     ${BOARD_NAME} != "au250" -a \
     ${BOARD_NAME} != "au200" -a \
     ${BOARD_NAME} != "au50"  -a \
     ${BOARD_NAME} != "vcu1525" ] ; then 
	echo "Error: ${BOARD_NAME} is not supported."
	echo "    Supported boards are au280, au250, au200, au50, and vcu1525."
	return -1
else
	board_name=`echo "puts [get_board_parts -quiet -latest_file_version \"*:${BOARD_NAME}:*\"]" | vivado -nolog -nojournal -mode tcl | grep xilinx` 
	if [ ${BOARD_NAME} = "au280" ] ; then
		device="xcu280-fsvh2892-2L-e"
	elif [ ${BOARD_NAME} = "au250" ] ; then
		device="xcu250-figd2104-2L-e"
	elif [ ${BOARD_NAME} = "au200" ] ; then
		device="xcu200-fsgd2104-2-e"
	elif [ ${BOARD_NAME} = "au50" ] ; then
		device="xcu50-fsvh2104-2-e"
	elif [ ${BOARD_NAME} = "vcu1525" ] ; then
		device="xcvu9p-fsgd2104-2L-e"
	fi
fi

vivado_version=`echo $XILINX_VIVADO | awk -F "/" 'NF>1{print $NF}'`
if [ -z ${vivado_version} ]; then
	echo "Error: please source vivado scripts. e.g.) /tools/Xilinx/Vivado/2019.2/settings64.sh"
	return -1
fi

if [ ${VERSION} != ${vivado_version} ] ; then
	echo "Error: you don't have proper Vivado version (${VERSION})."
	return -1
fi

echo "[ok]    Vivado Version (${VERSION}) has been checked."
echo "     BOARD_NAME     :   ${BOARD_NAME}"
echo "Done..."

export BOARD=${board_name}
export DEVICE=${device}