#!/bin/sh

#对于非svn上的压缩包，一般比较大，需要构造出相应的目录，以便其它模块编译使用
#如果已经手动创建对应目录，则不使用相关包重新生成
curr_dir=`pwd`
third_party_dir=$curr_dir/../../third-party

#相关函数
source $curr_dir/function.sh

#构造10版本的dbdriver编译依赖的目录结构
function oracle_client_create_10()
{
	#从oracle官网下载的相关包
	oracle_client_lib_10_package=$third_party_dir/basic-10.2.0.5.0-linux-x64.zip
	oracle_client_sdk_10_package=$third_party_dir/sdk-10.2.0.5.0-linux-x64.zip
	#解压后的目录为instantclient_10_2
	ORACLE_HOME_10=$third_party_dir/instantclient_10_2
	
	#防止重复操作
	if [ ! -d $ORACLE_HOME_10 ]
	then
		echo "build dir ORACLE_HOME_10=$ORACLE_HOME_10 ..."
		
		cd $third_party_dir
		uncompress_package $oracle_client_lib_10_package && uncompress_package $oracle_client_sdk_10_package
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress oracle 10 package failed"
			rm -rf $ORACLE_HOME_10
			return 1
		fi
		
		mkdir -p $ORACLE_HOME_10/{lib,rdbms/public}
		mv $ORACLE_HOME_10/sdk/include/* $ORACLE_HOME_10/rdbms/public
		mv $ORACLE_HOME_10/lib*.so* $ORACLE_HOME_10/lib
		ln -s $ORACLE_HOME_10/lib/libclntsh.so.10.1 $ORACLE_HOME_10/lib/libclntsh.so
	fi
}

#构造11版本的dbdriver编译依赖的目录结构
function oracle_client_create_11()
{
	#从oracle官网下载的相关包
	oracle_client_lib_11_package=instantclient-basic-linux.x64-11.2.0.4.0.zip
	oracle_client_sdk_11_package=instantclient-sdk-linux.x64-11.2.0.4.0.zip
	#解压后的目录为instantclient_11_2
	ORACLE_HOME_11=$third_party_dir/instantclient_11_2
	
	if [ ! -d $ORACLE_HOME_11 ]
	then
		echo "build dir ORACLE_HOME_11=$ORACLE_HOME_11 ..."
		
		cd $third_party_dir
		uncompress_package $oracle_client_lib_11_package && uncompress_package $oracle_client_sdk_11_package
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress oracle 11 package failed"
			rm -rf $ORACLE_HOME_11
			return 1
		fi
		
		mkdir -p $ORACLE_HOME_11/{lib,rdbms/public}
		mv $ORACLE_HOME_11/sdk/include/* $ORACLE_HOME_11/rdbms/public
		mv $ORACLE_HOME_11/lib*.so* $ORACLE_HOME_11/lib
		ln -s $ORACLE_HOME_11/lib/libclntsh.so.11.1 $ORACLE_HOME_11/lib/libclntsh.so
	fi
}

function zookeeper_create()
{
	zookeeper_package=$third_party_dir/zookeeper-3.4.9.tar.gz
	zookeeper_src_dir=`get_package_prefix $zookeeper_package`
	
	#即ZOOKEEPER_HOME的路径
	zookeeper_setup_dir=$third_party_dir/zookeeper_setup
	
	if [ ! -d $zookeeper_setup_dir ]
	then
		echo "build dir zookeeper_setup_dir=$zookeeper_setup_dir ..."
		
		cd $third_party_dir
		uncompress_package $zookeeper_package
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress $zookeeper_package failed"
			return 1
		fi
		
		mkdir -p $zookeeper_setup_dir
		
		cd $zookeeper_src_dir/src/c
		./configure --prefix=$zookeeper_setup_dir

		make && make install
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:make zookeeper failed!"
			rm -rf $zookeeper_setup_dir
			return 1
		fi
	fi
}

#从timesten原始安装包里获取相关程序和库等，具体需要根据包的结构来处理，这里使用timesten112280.linux8664.tar.gz
#由于tt压缩包里仍含有压缩包，这里简单处理
#一是为了编译dbdriver依赖的TT_HOME，二是用来获取源文件打包入网测试版本
function timesten_create()
{
	timesten_package=$third_party_dir/timesten112280.linux8664.tar.gz
	#解压后的目录名
	timesten_src_dir=$third_party_dir/linux8664
	
	#内层压缩包所在路径
	local main_package_dir=$timesten_src_dir/LINUX8664
	local common_package=$main_package_dir/common.tar.bz2
	local ttserver_package=$main_package_dir/ttserver.tar.bz2
	
	#由于common和ttserver包解压后不是顶层一个目录，且没有重复项，这里将其解压到同一目录，也即TT_HOME
	#如果还解压其它，注意防止同样的目录下相同文件名存在覆盖
	local timesten_setup_dir=$third_party_dir/timesten_setup
	
	if [ ! -d $timesten_setup_dir ]
	then
		echo "build dir timesten_setup_dir=$timesten_setup_dir ..."
		
		cd $third_party_dir
		uncompress_package $timesten_package
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress_package $timesten_package failed!"
			return 1
		fi
		
		mkdir -p $timesten_setup_dir
		
		cd $main_package_dir
		uncompress_package $common_package $timesten_setup_dir && uncompress_package $ttserver_package $timesten_setup_dir
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:uncompress_package $common_package or $ttserver_package failed!"
			rm -rf $timesten_setup_dir
			return 1
		fi
	fi
}

function usage_info()
{
	echo "usage:"
	echo "$0 [-l \"$g_compile_target\"]"
	
	echo ""
	echo "-l:specify the module to create, one or more, default is all"
}

g_compile_target="oracle_client zookeeper timesten"

if [ $# -ge 1 ]
then
	while getopts ':l:' OPT
	do
		case $OPT in
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

#每个module编译日志目录，编译过程日志，失败的话可以方便查看
log_dir=$curr_dir/log
mkdir -p $log_dir

for i in $g_compile_target
do
	echo "preprocess module:$i wait..."
	
	tmp_log_file_name=$log_dir/$i"_preprocess_log"
	
	case $i in
		oracle_client)
			oracle_client_create_10 > $tmp_log_file_name 2>&1 && oracle_client_create_11 >> $tmp_log_file_name 2>&1
			;;
		zookeeper)
			zookeeper_create > $tmp_log_file_name 2>&1
			;;
		timesten)
			timesten_create > $tmp_log_file_name 2>&1
			;;
		*)
			echo "not support module:$i"
			exit 1
			;;
	esac
	
	if [ $? -ne 0 ]
	then
		echo "preprocess module:$i failed"
		exit 1
	fi
	
	echo "preprocess module:$i success"
done
