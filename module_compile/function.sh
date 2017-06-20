#!/bin/sh

#压缩包解压后的目录名
function get_package_prefix()
{
	if [ $# -ne 1 ]
	then
		echo "$FUNCNAME:usage:$FUNCNAME filename"
		return 1
	fi
	
	local filename=$1
	local prefix_str
	
	if [[ "$filename" =~ ".tar.gz" ]]
	then
		prefix_str=`echo ${filename%.tar.gz}`
	elif [[ "$filename" =~ ".tar.bz2" ]]
	then
		prefix_str=`echo ${filename%.tar.bz2}`
	elif [[ "$filename" =~ ".tar.xz" ]]
	then
		prefix_str=`echo ${filename%.tar.xz}`
	elif [[ "$filename" =~ ".zip" ]]
	then
		prefix_str=`echo ${filename%.zip}`
	else
		echo "$FUNCNAME:not support uncompress file:$filename"
		return 1
	fi
	
	echo $prefix_str
}

#主要适合压缩包里面顶层只有一层目录结构的情况
function uncompress_package()
{
	if [ $# -lt 1 ]
	then
		echo "$FUNCNAME:$LINENO:usage:$FUNCNAME filename [dest_dir]"
		return 1
	fi
	
	if [ ! -f $1 ]
	then
		echo "$FUNCNAME:$LINENO:filename $1 is not exist"
		return 1
	fi
	
	local filename=$1
	local dest_cmd=
	#suffix_str=`echo $filename | awk -F "." '{print $NF}'`
	if [ $# -eq 2 ]
	then
		local dest_dir=$2
		
		if [[ "$filename" =~ ".tar." ]]
		then
			dest_cmd=" -C $dest_dir"
		elif [[ "$filename" =~ ".zip" ]]
		then
			dest_cmd=" -d $dest_dir"
		fi
	fi
	
	if [[ "$filename" =~ ".tar.gz" ]]
	then
		tar -xzf $filename $dest_cmd
	elif [[ "$filename" =~ ".tar.bz2" ]]
	then
		tar -jxf $filename $dest_cmd
	elif [[ "$filename" =~ ".tar.xz" ]]
	then
		local prefix_str=`echo ${filename%.xz}`
		xz -dk $filename
		tar -xf $prefix_str $dest_cmd
	elif [[ "$filename" =~ ".zip" ]]
	then
		#覆盖解压
		unzip -oq $filename $dest_cmd
	else
		echo "$FUNCNAME:$LINENO:not support uncompress file:$filename"
		return 1
	fi
}

#0：不需要更新 1：错误 2：有新的更新
function check_svn_update()
{
	if [ $# -ne 3 ]
	then
		echo "$FUNCNAME:$LINENO:usage:$FUNCNAME dirname usename passwd"
		return 1
	fi
	
	if [ ! -d $1 ]
	then
		echo "$FUNCNAME:$LINENO:dirname $1 is not exist"
		return 1
	fi
	
	local tmp_src_dir=$1
	local tmp_usename=$2
	local tmp_passwd=$3
	
	cd $tmp_src_dir
	
	local_revision=`svn info | grep "Last Changed Rev:" | awk '{print $4}'`
	URL=`svn info | grep URL: | awk '{print $2}'`
	svn_revision=`svn info $URL --username $tmp_usename --password $tmp_passwd | grep "Last Changed Rev:" | awk '{print $4}'`
	if [ "-$svn_revision" = "-" ]
	then
		echo "$FUNCNAME:$LINENO:get remote svn info failed: $1"
		return 1
	fi
	
	#只在有需要更新时才更新，防止工程比较大时花费较多时间（即使不更新）
	if [[ $local_revision < $svn_revision ]]
	then
		echo "svn up..."
		svn up > /dev/null
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:svn up failed: $1"
			return 1
		fi
		
		return 2
	fi
}

#0：成功，没有更新操作 1：出错 2：svn目录有更新
function svn_checkout_up()
{	
	if [ $# != 4 ]
	then
		echo "$FUNCNAME:$LINENO:usage $FUNCNAME url local_svn_dir usename passwd"
		return 1
	fi
	
	local tmp_url_value=$1
	local tmp_local_svn_dir=$2
	local tmp_usename=$3
	local tmp_passwd=$4
	
	#是否已经svn checkout，1的话只需update
	local tmp_svn_checkout_flag=0
	
	if [ ! -d $tmp_local_svn_dir ]
	then
		tmp_svn_checkout_flag=1
	else
		cd $tmp_local_svn_dir
		svn info > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			tmp_svn_checkout_flag=0
		else
			tmp_svn_checkout_flag=1
		fi
	fi
	
	if [ $tmp_svn_checkout_flag -eq 1 ]
	then
		echo "svn checkout..."
		svn checkout $tmp_url_value --username $tmp_usename --password $tmp_passwd $tmp_local_svn_dir > /dev/null
		if [ $? -ne 0 ]
		then
			echo "$FUNCNAME:$LINENO:svn checkout failed: $tmp_url_value"
			return 1
		fi
		
		return 2
	else
		check_svn_update $tmp_local_svn_dir $tmp_usename $tmp_passwd
		case $? in
			1)
				echo "$FUNCNAME:$LINENO:svn update failed: $tmp_local_svn_dir"
				return 1
				;;
			2)
				#有新的更新
				return 2
				;;
		esac
	fi
}
