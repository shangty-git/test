#!/bin/sh

curr_dir=`pwd`
third_party_dir=$curr_dir/../../third-party

#相关函数
source $curr_dir/function.sh

#########################################
#svn下载代码相关
#########################################
#svn checkout到本地目录
dmdb_server_dir=$curr_dir/../../Server
dmdb_connector_dir=$curr_dir/../../Driver/dmdb-connector-c-1.0.1-src
bdb_dir=$curr_dir/../../Storage/BerkeleyDB
platform_dir=$third_party_dir/platform
dbdriver_dir=$third_party_dir/dbdriver
tdal_dir=$third_party_dir/tbs
#svn路径
url_third_party=http://192.168.161.59:8888/svn/TD/SourceCode/1_Develop/14_DMDB/third-party
url_dmdb_server=http://192.168.161.59:8888/svn/TD/SourceCode/1_Develop/14_DMDB/Server
url_dmdb_connector=http://192.168.161.59:8888/svn/TD/SourceCode/1_Develop/14_DMDB/Driver/dmdb-connector-c-1.0.1-src
url_bdb=http://192.168.161.59:8888/svn/TD/SourceCode/1_Develop/14_DMDB/Storage/BerkeleyDB
url_platform=http://202.105.139.114:8080/svn/DT/SourceCode/Develop/platform
url_dbdriver=http://202.105.139.114:8080/svn/DT/SourceCode/Develop/dbdriver
url_tdal=http://192.168.161.59:8888/svn/TD/SourceCode/1_Develop/08_TDAL/tbs

declare -A map_localDir_url=(
[$third_party_dir]=$url_third_party
[$dmdb_server_dir]=$url_dmdb_server
[$dmdb_connector_dir]=$url_dmdb_connector
[$bdb_dir]=$url_bdb
[$platform_dir]=$url_platform
[$dbdriver_dir]=$url_dbdriver
[$tdal_dir]=$url_tdal
)

username=penglj
password=penglj

username_sec=shangtuanyuan
password_sec=zxcv1234

#########################################
#需要编译、安装的
#########################################
#是否需要重新编译相关配置文件
compile_flag_file=compile_flag.conf

#相关压缩包名
os_version=`cat /etc/redhat-release`
if [[ "$os_version" =~ "release 6" ]]
then
	glib_package=$third_party_dir/glib-2.28.8.tar.xz
elif [[ "$os_version" =~ "release 7" ]]
then
	glib_package=$third_party_dir/glib-2.42.2.tar.xz
fi

libevent_package=$third_party_dir/libevent-2.0.22-stable.tar.gz
libffi_package=$third_party_dir/libffi-3.2.1.tar.gz

#依赖压缩包安装
declare -A map_module_pkg_compile=(
[glib]=$glib_package
[libevent]=$libevent_package
[libffi]=$libffi_package
)

#压缩包和所在路径的关系，以便映射svn url路径进行下载
#由于rapidjson和rapidxml在下载tdal时已经包含了，这里不做处理
declare -A map_pkg_localDir=(
[$glib_package]=$third_party_dir
[$libevent_package]=$third_party_dir
[$libffi_package]=$third_party_dir
)

#依赖源代码目录安装
declare -A map_module_localDir_compile=(
[dmdb_server]=$dmdb_server_dir
[dmdb_connector]=$dmdb_connector_dir
[bdb]=$bdb_dir
[platform]=$platform_dir
[dbdriver]=$dbdriver_dir
[tdal]=$tdal_dir
)

#压缩包解压到的目录，具体还要看解压出来的具体目录是什么进行赋值，且顶层为一个目录的情况
#对于顶层为多个目录的，需要特殊处理解压到一个目录下
glib_src_dir=`get_package_prefix $glib_package`
libevent_src_dir=`get_package_prefix $libevent_package`
libffi_src_dir=`get_package_prefix $libffi_package`
#非解压包相关源文件路径
bdb_src_dir=$bdb_dir
dmdb_server_src_dir=$dmdb_server_dir
dmdb_connector_src_dir=$dmdb_connector_dir
tdal_src_dir=$tdal_dir
dbdriver_src_dir=$dbdriver_dir
platform_src_dir=$platform_dir

#相关安装目录
glib_setup_dir=$third_party_dir/glib_setup
libevent_setup_dir=$third_party_dir/libevent_setup
libffi_setup_dir=$third_party_dir/libffi_setup
bdb_setup_dir=$third_party_dir/bdb_setup
dmdb_server_setup_dir=$third_party_dir/dmdb_server_setup
dmdb_connector_setup_dir=$third_party_dir/dmdb_connector_setup
tdal_setup_dir=
dbdriver_setup_dir=
platform_setup_dir=

declare -A map_src_dir=(
[glib]=$glib_src_dir
[libevent]=$libevent_src_dir
[libffi]=$libffi_src_dir
[bdb]=$bdb_src_dir
[dmdb_server]=$dmdb_server_src_dir
[dmdb_connector]=$dmdb_connector_src_dir
[tdal]=$tdal_src_dir
[dbdriver]=$dbdriver_src_dir
[platform]=$platform_src_dir
)
declare -A map_setup_dir=(
[glib]=$glib_setup_dir
[libevent]=$libevent_setup_dir
[libffi]=$libffi_setup_dir
[bdb]=$bdb_setup_dir
[dmdb_server]=$dmdb_server_setup_dir
[dmdb_connector]=$dmdb_connector_setup_dir
[tdal]=$tdal_setup_dir
[dbdriver]=$dbdriver_setup_dir
[platform]=$platform_setup_dir
)

############################
#编译dbdriver依赖的环境变量
dbdriver_compile_arr=(oracle mysql timesten bdb)

#非svn包构造的目录，参看脚本preprocess_local_pack.sh
ORACLE_HOME_10=$third_party_dir/instantclient_10_2
ORACLE_HOME_11=$third_party_dir/instantclient_11_2
export TT_HOME=$third_party_dir/timesten_setup

export MYSQL_HOME=$dmdb_connector_setup_dir
export BDB_HOME=$bdb_setup_dir
############################

export PLATFORM_HOME=$platform_dir
export DBDRIVER_HOME=$dbdriver_dir

#tdal依赖的环境变量
export TBS_HOME=$tdal_dir
export RAPIDXML_HOME=$TBS_HOME/third-party
export RAPIDJSON_HOME=$TBS_HOME/third-party
#非svn包构造的目录，参看脚本preprocess_local_pack.sh
export ZOOKEEPER_HOME=$third_party_dir/zookeeper_setup

#dmdb_server编译依赖环境变量
export LIBTOOLFLAGS=--verbose
export MANAGER_HOME=$TBS_HOME
export BLOCKQUENE_HOME=$TBS_HOME

#glib依赖环境变量
export PKG_CONFIG_PATH=$libffi_setup_dir/lib/pkgconfig

#有些多级编译依赖时需要，
#如tdal的例子程序在链接libtdaldrv.so时，需要libmgrutil.so，而libmgrutil.so又需要zookeeper的库
#oracle库也存在该情况
export LD_LIBRARY_PATH=$ZOOKEEPER_HOME/lib:$ORACLE_HOME_10/lib:$ORACLE_HOME_11/lib:$TBS_HOME/lib:$PLATFORM_HOME/lib:$DBDRIVER_HOME/lib:$LD_LIBRARY_PATH

#将当前目录下的有关环境变量导出到文件中，以便单模块编译时使用
function export_env_file()
{
	local generate_env_file=$curr_dir/generate_env.sh

	rm -rf $generate_env_file
	echo "#export ORACLE_HOME=$ORACLE_HOME_10" >> $generate_env_file
	echo "export ORACLE_HOME=$ORACLE_HOME_11" >> $generate_env_file
	echo "export MYSQL_HOME=$MYSQL_HOME" >> $generate_env_file
	echo "export TT_HOME=$TT_HOME" >> $generate_env_file
	echo "export BDB_HOME=$BDB_HOME" >> $generate_env_file

	echo "export PLATFORM_HOME=$PLATFORM_HOME" >> $generate_env_file
	echo "export DBDRIVER_HOME=$DBDRIVER_HOME" >> $generate_env_file
	echo "export RAPIDXML_HOME=$RAPIDXML_HOME" >> $generate_env_file
	echo "export RAPIDJSON_HOME=$RAPIDJSON_HOME" >> $generate_env_file
	echo "export ZOOKEEPER_HOME=$ZOOKEEPER_HOME" >> $generate_env_file
	echo "export TBS_HOME=$TBS_HOME" >> $generate_env_file
	echo "export MANAGER_HOME=$MANAGER_HOME" >> $generate_env_file
	echo "export BLOCKQUENE_HOME=$BLOCKQUENE_HOME" >> $generate_env_file
	echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> $generate_env_file
	#echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $generate_env_file
}

#通过压缩包解压，并判断是否需要编译、安装
#0：成功，不需要操作 1：错误 2：需要编译 
function uncompress_module_package()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	local tmp_module_name=$1
	local tmp_package_name=${map_module_pkg_compile[$tmp_module_name]}
	if [ ! -f $tmp_package_name ]
	then
		echo "$FUNCNAME:$LINENO:$tmp_package_name is not exist"
		return 1
	fi
	
	#解压后的目录
	local uncompress_dir_name=${map_src_dir[$tmp_module_name]}
	if [ "-$uncompress_dir_name" = "-" ]
	then
		echo "$FUNCNAME:$LINENO:get uncompress_dir_name failed"
		return 1
	fi
	
	local tmp_res=0
	
	#目录不存在，解压
	if [ ! -d $uncompress_dir_name ]
	then
		mkdir -p $uncompress_dir_name
		cd `dirname $uncompress_dir_name`
		
		#不同的压缩包可能需要解压成不同的目录，这里可以根据模块具体处理
		case $tmp_module_name in
			*)
			uncompress_package $tmp_package_name
			tmp_res=$?
			;;
		esac
		
		if [ $tmp_res -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress $tmp_package_name failed"
			rm -rf $uncompress_dir_name
			return 1
		fi
		
		return 2
	fi
}

#0：成功，不需要编译操作 1：错误 2：有更新需要编译
function svn_option()
{
	#如果不使用svn，则默认为有更新需要编译
	if [ $g_use_svn_flag -eq 0 ]
	then
		return 2
	fi
	
	if [ $# -ne 3 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name url local_svn_dir"
		return 1
	fi
	
	local tmp_module_name=$1
	local tmp_url_value=$2
	local tmp_local_svn_dir=$3
	
	if [ "$tmp_module_name" = "platform" -o "$tmp_module_name" = "dbdriver" ]
	then
		svn_checkout_up $tmp_url_value $tmp_local_svn_dir $username $password
	else
		svn_checkout_up $tmp_url_value $tmp_local_svn_dir $username_sec $password_sec
	fi

	case $? in
		1)
			echo "$FUNCNAME:$LINENO:svn_checkout_up $tmp_url_value failed"
			return 1
			;;
		2)
			return 2
			;;
	esac
}

#对于通过源目录直接编译的预处理
#0：成功，不需要编译操作 1：错误 2：svn代码有更新
function preprocess_src_dir_compile()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	local tmp_module_name=$1
	
	#对于使用svn源文件目录编译的（非压缩包），如果有更新需要编译
	local tmp_local_svn_dir=${map_module_localDir_compile[$tmp_module_name]}
	if [ "-$tmp_local_svn_dir" != "-" ]
	then
		local tmp_url_value=${map_localDir_url[$tmp_local_svn_dir]}
		if [ "-$tmp_url_value" != "-" ]
		then
			svn_option $tmp_module_name $tmp_url_value $tmp_local_svn_dir
			case $? in
				1)
					echo "$FUNCNAME:$LINENO:svn_option $tmp_url_value failed"
					return 1
					;;
				2)
					return 2
					;;
			esac
		fi
	fi
}

#对于通过压缩包编译的预处理
#0：成功，不需要编译操作 1：错误 2：源目录不存在需解压
function preprocess_package_compile()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	local tmp_module_name=$1
	local tmp_package_name=${map_module_pkg_compile[$tmp_module_name]}
	if [ "-$tmp_package_name" != "-" ]
	then
		local tmp_local_svn_dir=${map_pkg_localDir[$tmp_package_name]}
		if [ "-$tmp_local_svn_dir" != "-" ]
		then
			local tmp_url_value=${map_localDir_url[$tmp_local_svn_dir]}
			
			if [ "-$tmp_url_value" != "-" ]
			then
				#下载相关的压缩包
				#对于压缩包有更新时，通过进行后续解压来判断是否需要编译
				svn_option $tmp_module_name $tmp_url_value $tmp_local_svn_dir
				case $? in
					1)
						echo "$FUNCNAME:$LINENO:svn_option $tmp_url_value failed"
						return 1
						;;
					2)
						;;
				esac
			fi
		fi
	
		uncompress_module_package $tmp_module_name
		case $? in
			1)
				echo "$FUNCNAME:$LINENO:uncompress_module_package $tmp_package_name failed"
				return 1
				;;
			2)
				return 2
				;;
		esac
	fi
}

#svn更新，压缩包解压等操作，并判断是否需要编译
#0：成功，不需要编译操作 1：错误 2：需要重新编译
function preprocess_compile()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	local tmp_module_name=$1
	local tmp_local_dir_compile=${map_module_localDir_compile[$tmp_module_name]}
	local tmp_package_name_compile=${map_module_pkg_compile[$tmp_module_name]}
	local tmp_res=0

	clean_option $tmp_module_name
	
	check_recompile $tmp_module_name
	case $? in
		0)
			#不需要编译安装
			return 0
			;;
		1)
			return 1
			;;
		2)
			#需要编译安装、需要后续的获取源码的操作
			;;
	esac
	
	#对于使用svn源文件目录编译的
	if [ "-$tmp_local_dir_compile" != "-" ]
	then
		preprocess_src_dir_compile $tmp_module_name
		tmp_res=$?
	#对于使用压缩包进行编译的
	elif [ "-$tmp_package_name_compile" != "-" ]
	then
		preprocess_package_compile $tmp_module_name
		tmp_res=$?
	else
		echo "$FUNCNAME:$LINENO:not src dir or package compile"
		return 1
	fi
	
	case $tmp_res in
		1)
			return 1
			;;
		*)
			#对于其它情况默认需要编译
			return 2
			;;
	esac
}

#每个模块重新编译时可能需要做的一些清理操作
#这里只是通用的，可能需要根据具体模块做不同的处理
function clean_option()
{
	if [ $g_clean_flag -eq 0 ]
	then
		return 0
	fi
	
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	local tmp_module_name=$1
	local tmp_src_dir=${map_src_dir[$tmp_module_name]}
	local tmp_setup_dir=${map_setup_dir[$tmp_module_name]}
	local tmp_res=0
	
	case $tmp_module_name in
		bdb)
			;;
		libffi|glib|libevent)
			cd $tmp_src_dir && make clean
			;;
		zookeeper)
			;;
		dmdb_connector)
			;;
		dbdriver)
			;;
		tdal)
			;;
		dmdb_server)
			;;
		platform)
			;;
		*)
			echo "$FUNCNAME:$LINENO:$tmp_module_name is not support"
			tmp_res=1
			break
			;;
	esac
	
	if [ $tmp_res -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:clean failed"
		return 1
	fi
}

#判断是否需要重新编译
#1、对于需要单独安装目录的，则判断是否已经存在，如果存在则不再编译安装
#2、对于直接在源目录下编译并生成到当前目录的，默认需要编译
#3、对于如果编译失败，但是安装目录创建的，需要单独编译该模块，可手动编译，也可通过选项-f强制编译
#4、为了可以手动构建该目录（如：从其它已经建好的目录拷贝过来），而不必使用相关安装包
#return 0:不需要编译安装 1:出错 2:需要编译安装
function check_recompile()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME module_name"
		return 1
	fi
	
	#如果强制必须再编译一次，防止上次编译出错，但是会有后面目录的判断
	if [ $g_force_compile_flag -eq 1 ]
	then
		return 2
	fi
	
	local tmp_module_name=$1
	local tmp_setup_dir=${map_setup_dir[$tmp_module_name]}
	local tmp_src_dir=${map_src_dir[$tmp_module_name]}
	local tmp_res=0
	
	case $tmp_module_name in
		libffi|glib|libevent|bdb|dmdb_connector|dmdb_server)
			#如果安装目录已经存在，则跳过安装
			if [ -d $tmp_setup_dir ]
			then
				tmp_res=0
			else
				tmp_res=2
			fi
			;;
		dbdriver|tdal)
			if [ -d $tmp_src_dir/lib ]
			then
				tmp_res=0
			else
				tmp_res=2
			fi
			;;
		platform)
			if [ -f $tmp_src_dir/lib/libplatform.so ]
			then
				tmp_res=0
			else
				tmp_res=2
			fi
			;;
		*)
			echo "$FUNCNAME:$LINENO:$tmp_module_name is not support"
			tmp_res=1
			;;
	esac
	
	return $tmp_res
}

function platform_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME src_dir"
		return 1
	fi
	
	cd $1
	./platform_make.sh
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:platform_make make failed!"
		return 1
	fi
}

function basic_compile()
{
	if [ $# != 2 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME src_dir setup_dir"
		return 1
	fi
	
	cd $1
	./configure --prefix=$2

	make && make install
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:$1 make failed!"
		return 1
	fi
}

function bdb_compile()
{
	if [ $# != 2 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir setup_dir"
		return 1
	fi
	
	cd $1/build_unix
	../dist/configure --prefix=$2 --enable-sql --enable-sql_compat

	make && make install
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:bdb make failed!"
		return 1
	fi	
}

function dmdb_connector_compile()
{
	if [ $# != 2 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME src_dir setup_dir"
		return 1
	fi
	
	cd $1
	cmake . -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$2

	make VERBOSE=1 && make install
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:$1 make failed!"
		return 1
	fi
}

function tdal_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	#构造编译依赖的有关目录结构，rapidxml和rapidjson
	cd $1/third-party
	chmod u+x compile_env.sh
	./compile_env.sh
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:tdal compile_env.sh failed!"
		return 1
	fi
	
	cd $1 && make prebuild && cd manager && make
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:tdal manager make failed!"
		return 1
	fi
	
	cd $1 && make
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:tdal make failed!"
		return 1
	fi
}

function dmdb_server_compile()
{
	if [ $# != 2 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir setup_dir"
		return 1
	fi
	
	cd $1
	./autogen.sh
	./configure CC=/usr/bin/g++ CFLAGS="-g -O2 -fpermissive" --prefix=$2 \
	LDFLAGS="-L$libevent_setup_dir/lib -L$glib_setup_dir/lib" \
	GLIB_CFLAGS="-I$glib_setup_dir/include/glib-2.0" \
	CPPFLAGS="-I$libevent_setup_dir/include" --disable-dependency-tracking
	
	make && make install
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:dmdb server make failed!"
		return 1
	fi
}

#oracle基于10、11编译两个版本
function dbdriver_oracle_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	local tmp_src_dir=$1
	local tmp_lib_dir=$tmp_src_dir/lib
	
	cd $tmp_src_dir
	
	if [ "-$ORACLE_HOME_10" != "-" -a -d $ORACLE_HOME_10 ]
	then
		export ORACLE_HOME=$ORACLE_HOME_10
		
		rm -rf $tmp_lib_dir/liboradrv.so
		./dbdriver_make.sh clean all oracle
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make oracle 10 failed!"
			return 1
		fi

		#修改库名为10标示的驱动库名
		cp $tmp_lib_dir/liboradrv.so $tmp_lib_dir/liboradrv.so.10
		echo "$FUNCNAME:$LINENO:dbdriver make oracle 10 success!"
	else
		echo "$FUNCNAME:$LINENO:there is no ORACLE_HOME_10 or dir is not exist to compile!"
	fi
	
	if [ "-$ORACLE_HOME_11" != "-" -a -d $ORACLE_HOME_11 ]
	then
		export ORACLE_HOME=$ORACLE_HOME_11
		
		rm -rf $tmp_lib_dir/liboradrv.so
		./dbdriver_make.sh clean all oracle
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make oracle 11 failed!"
			return 1
		fi
		
		#修改库名为11标示的驱动库名，10、11都存在时默认原来库名为11的
		cp $tmp_lib_dir/liboradrv.so $tmp_lib_dir/liboradrv.so.11
		echo "$FUNCNAME:$LINENO:dbdriver make oracle 11 success!"
	else
		echo "$FUNCNAME:$LINENO:there is no ORACLE_HOME_11 or dir is not exist to compile!"
	fi
}

#timesten基于自动提交和非自动提交编译两个版本
function dbdriver_timesten_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	local tmp_src_dir=$1
	local tmp_lib_dir=$tmp_src_dir/lib
	
	cd $tmp_src_dir
	
	if [ "-$TT_HOME" != "-" -a -d $TT_HOME ]
	then
		local tmp_timesten_commit_file=$tmp_src_dir/drivers/timesten/src/DCMDBPool.cpp
		
		#编译自动提交的
		sed -i "s/pCon->Connect(str, [01], env)/pCon->Connect(str, 0, env)/g" $tmp_timesten_commit_file
		./dbdriver_make.sh clean all timesten
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make timesten failed!"
			return 1
		fi
		#修改库名为自动提交标示
		cp $tmp_lib_dir/libttdrv.so $tmp_lib_dir/libttdrv_co.so
		echo "$FUNCNAME:$LINENO:dbdriver make timesten auto commit success!"
		
		#编译非自动提交的
		sed -i "s/pCon->Connect(str, [01], env)/pCon->Connect(str, 1, env)/g" $tmp_timesten_commit_file
		./dbdriver_make.sh clean all timesten
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make timesten failed!"
			return 1
		fi
		#修改库名为非自动提交标示，默认原名的为非自动提交库
		cp $tmp_lib_dir/libttdrv.so $tmp_lib_dir/libttdrv_no.so
		echo "$FUNCNAME:$LINENO:dbdriver make timesten not auto commit success!"
	else
		echo "$FUNCNAME:$LINENO:there is no TT_HOME or dir is not exist to compile!"
	fi
}

function dbdriver_mysql_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	local tmp_src_dir=$1
	local tmp_lib_dir=$tmp_src_dir/lib
	
	cd $tmp_src_dir
	
	if [ "-$MYSQL_HOME" != "-" -a -d $MYSQL_HOME ]
	then
		./dbdriver_make.sh mysql
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make mysql failed!"
			return 1
		fi
		
		echo "$FUNCNAME:$LINENO:dbdriver make mysql success!"
	else
		echo "$FUNCNAME:$LINENO:there is no MYSQL_HOME or dir is not exist to compile!"
	fi
}

function dbdriver_bdb_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	local tmp_src_dir=$1
	local tmp_lib_dir=$tmp_src_dir/lib
	
	cd $tmp_src_dir
	
	if [ "-$BDB_HOME" != "-" -a -d $BDB_HOME ]
	then
		./dbdriver_make.sh bdb
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:dbdriver make bdb failed!"
			return 1
		fi
		
		echo "$FUNCNAME:$LINENO:dbdriver make bdb success!"
	else
		echo "$FUNCNAME:$LINENO:there is no BDB_HOME or dir is not exist to compile!"
	fi
}

#默认编译oracle、timesten、mysql、bdb驱动库
#如果存在有关环境变量的目录则编译，否则跳过不编译
function dbdriver_compile()
{
	if [ $# != 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME:$LINENO src_dir"
		return 1
	fi
	
	local tmp_src_dir=$1
	
	dbdriver_oracle_compile $tmp_src_dir && dbdriver_mysql_compile $tmp_src_dir \
	&& dbdriver_timesten_compile $tmp_src_dir && dbdriver_bdb_compile $tmp_src_dir
	if [ $? -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:dbdriver make failed!"
		return 1
	fi
}

#0：成功 1：失败
function module_compile_setup()
{	
	local tmp_res=0
	
	#每个module编译日志目录，编译过程日志，失败的话可以方便查看
	local log_dir=$curr_dir/log
	mkdir -p $log_dir
	
	for i in $@
	do	
		
		local tmp_module_name=$i
		local tmp_src_dir=${map_src_dir[$tmp_module_name]}
		local tmp_setup_dir=${map_setup_dir[$tmp_module_name]}
		
		preprocess_compile $tmp_module_name
		case $? in
			0)
				echo "$FUNCNAME:$LINENO:$tmp_module_name is not need compile"
				continue
				;;
			1)
				echo "$FUNCNAME:$LINENO:preprocess_compile $tmp_module_name failed"
				tmp_res=1
				break
				;;
			2)
				#需要编译
				;;
			*)
				echo "$FUNCNAME:$LINENO:preprocess_compile $tmp_module_name, error return num"
				tmp_res=1
				break
				;;
		esac

		#当preprocess_compile之后目录才会存在或者手动上传
		if [ ! -d $tmp_src_dir ]
		then
			echo "$FUNCNAME:$LINENO:$tmp_src_dir is not exist"
			tmp_res=1
			break
		fi
		
		#需要setup的才建立目录，防止一些安装需要事先建立目录
		if [[ "-$tmp_setup_dir" != "-" && ! -d $tmp_setup_dir ]]
		then
			mkdir -p $tmp_setup_dir
		fi
		
		#如果没有找到文件，忽略chmod错误
		find $tmp_src_dir -name "*.sh" | xargs chmod u+x > /dev/null 2>&1
		find $tmp_src_dir -name "configure" | xargs chmod u+x > /dev/null 2>&1
		
		local tmp_log_file_name=$log_dir/$tmp_module_name"_compile_log"
		
		echo "$FUNCNAME:$LINENO:$tmp_module_name is compiling, wait..."
		
		case $tmp_module_name in
			bdb)
				bdb_compile $tmp_src_dir $tmp_setup_dir > $tmp_log_file_name 2>&1
				;;
			libffi|glib|libevent)
				basic_compile $tmp_src_dir $tmp_setup_dir > $tmp_log_file_name 2>&1
				;;
			dmdb_connector)
				dmdb_connector_compile $tmp_src_dir $tmp_setup_dir > $tmp_log_file_name 2>&1
				;;
			dbdriver)
				dbdriver_compile $tmp_src_dir > $tmp_log_file_name 2>&1
				;;
			tdal)
				tdal_compile $tmp_src_dir > $tmp_log_file_name 2>&1
				;;
			dmdb_server)
				#module_compile_setup libffi glib libevent && dmdb_server_compile $tmp_src_dir $tmp_setup_dir > $tmp_log_file_name 2>&1
				dmdb_server_compile $tmp_src_dir $tmp_setup_dir > $tmp_log_file_name 2>&1
				;;
			platform)
				platform_compile $tmp_src_dir > $tmp_log_file_name 2>&1
				;;
			*)
				echo "$FUNCNAME:$LINENO:$tmp_module_name is not support"
				tmp_res=1
				break
				;;
		esac
		
		if [ $? -ne 0 ]
		then
			#对于编译失败的，删除相应的安装目录，以便进行可重入判断（如果没有该目录，则需要编译）
			if [[ "-$tmp_setup_dir" != "-" && -d $tmp_setup_dir ]]
			then
				rm -rf $tmp_setup_dir
			fi
			
			tmp_res=1
			break
		else
			echo "$FUNCNAME:$LINENO:$tmp_module_name compile success"
		fi
		
		#编译成功则删除相关编译日志
		#rm -f $tmp_log_file_name
	done
	
	if [ $tmp_res -ne 0 ]
	then
		echo "$FUNCNAME:$LINENO:$tmp_module_name compile failed"
		return 1
	fi
}

function usage_info()
{
	echo "usage:"
	echo "$0 [-c][-n][-f]"
	echo "	 [-l \"$g_compile_target\"]"
	
	echo ""
	echo "-c:specify clean option before compile, default is not clean"
	echo "-n:specify not need svn option before compile, default is need"
	echo "-f:specify force to compile(in order to recompile if the last time compile is failed or code is update), default is not force"
	echo "-l:specify the compile module list need to compile, one or more, default is all"
}

g_clean_flag=0
g_use_svn_flag=1
g_force_compile_flag=0

g_compile_target="libffi glib libevent bdb platform dmdb_connector dbdriver tdal dmdb_server"

if [ $# -ge 1 ]
then
	while getopts ':ncfl:' OPT
	do
		case $OPT in
			c)
				g_clean_flag=1
				;;
			n)
				g_use_svn_flag=0
				;;
			f)
				g_force_compile_flag=1
				;;
			l)
				g_compile_target="$OPTARG"
				;;
			*)
				usage_info
				exit 1
				;;
		esac
	done
fi

#预先建立一定结构的目录，以便其它模块编译使用，
#主要为非svn上的包（包比较大，且版本什么的可能不同），需要手动上传并构造出一定的目录
#涉及目录为TT_HOME,ZOOKEEPER_HOME,ORACLE_HOME_10,ORACLE_HOME_11
cd $curr_dir
chmod u+x preprocess_local_pack.sh
./preprocess_local_pack.sh
if [ $? -ne 0 ]
then
	echo "preprocess create dir failed!"
	exit 1
fi

export_env_file

module_compile_setup $g_compile_target
if [ $? -ne 0 ]
then
	echo "module_compile_setup failed!"
	exit 1
fi
