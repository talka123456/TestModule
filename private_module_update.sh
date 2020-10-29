# ======================================== 设置组件配置信息 ====================================

# 默认推送的Spec仓库名称 必须设置有效的文件夹名称才会生效 获取路径 cd ~/.cocoapods/repos/
# 如果每个成员的本地Spec名称不同,则不设置默认值, 在脚本执行过程中去主动选择推送的私有Spec目录
readonly DEFAULT_REPO_DIR_NAME=""

# 存放你的Spec的地址, 不填写会导致无法repo push
# readonly PUSH_REPO_SOURCE=--sources="https://github.com/CocoaPods/Specs,git@gitlab.dealmoon.net:ios/Specs.git"
readonly PUSH_REPO_SOURCE=--sources="https://github.com/CocoaPods/Specs,https://github.com/talka123456/TestSpec.git"

if [ "${PUSH_REPO_SOURCE}" = "--sources=" ]
then
	echo_warning "未填写Spec地址, 请填写后重试..."
	exit 1;
fi

# ========================================= 自定义函数 =========================================
#打印时间
function displaysecs() {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( $D > 0 )) && printf '%d days ' $D
    (( $H > 0 )) && printf '%d hours ' $H
    (( $M > 0 )) && printf '%d minutes ' $M
    (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
    printf '%d seconds\n' $S
}

# 打印红色的文本内容 出现异常时打印
function echo_warning()
{
	if [[ ${#1} > 0 ]]; then
		echo "\033[31mwarning: ${1}\033[0m"
	fi
}

# 打印绿色的文本内容 正常流程会使用这个打印
function echo_success()
{
	if [[ ${#1} > 0 ]]; then
		echo "\033[32m${1}\033[0m"
	fi
}

# 必须输入数字才能继续后面的流程
INPUT_NUMBER=
function circle_input()
{
	INPUT_NUMBER=
	if [[ ${#1} == 0 ]]; then
		echo "circle_input func未传入参数"
		exit
	fi

	while [[ ! "$INPUT_NUMBER" =~ [0-9] ]];do
    read -p "${1}" INPUT_NUMBER
	done
}

# 自动计算tag值, tag格式为x.x.x, 默认为低位每次增加1, 到9进位
AUTO_TAG=
function auto_tag()
{
	old_tag=$1;
    v1=${old_tag:0:1}
    v2=${old_tag:2:1}
    v3=${old_tag:4:1}

    if [ ${v3} -ne '9' ] ; then
        v3=`expr ${v3} + 1`
    elif [ ${v2} -ne '9' ] ; then
        v2=`expr ${v2} + 1`
        v3=0
    else
        v1=`expr ${v1} + 1`
        v2=0
        v3=0
    fi

    AUTO_TAG="${v1}.${v2}.${v3}"
}

# function Resotre_Project_Site()
# {
# 	# 还原tag
# 	# 还原 version
# }

# 打印分割线
function log_line()
{
	echo "================"
}

#========================================= 获取当前git工作分支 =========================================

# 查看当前分支
BRANCH_NAME=$(git symbolic-ref --short -q HEAD)

if [ -z "${BRANCH_NAME}" ]
then
	echo_warning "未查找到git仓库,请检查后重试"
	exit 1;
fi

# 显示当前工作目录的分支号
echo_success "当前git工作分支为: ${BRANCH_NAME}"

log_line

#========================================= 判断工作区是否有未提交的代码 =========================================
# 查看是否有未提交的文件
files=`git status -s`
if [ -n "${files}" ] ; then
    echo_warning "存在未提交的文件"
	log_line

    echo_warning "${files}"
	log_line

    echo_warning "正在退出脚本..."
    exit 1;
fi

# =========================================== PodSpec文件读取处理 ===============================
# 查找podspec文件, 递归查找文件目录
PODSPEC_PATH=`find . -name "*.podspec"`
if [ -z "${PODSPEC_PATH}" ] ; then
    echo_warning "未找到podspec文件, 执行失败,正在退出脚本..."
    exit 1;
fi

# podspec文件名, 直接读取文件第二行内容为PODSPEC_NAME(限制比较大,要求podspec第二行为设置的podname, 也可以read文件遍历每行匹配读取)
# PODSPEC_NAME="${PODSPEC_PATH:2}"
PODSPEC_NAME=''
while read line
do
    # echo $line
    if [[ $line == s.name* ]]; then
    	# echo $line
    	# 匹配单引号或者双引号
		RE="\'([^\']*)\'"
		RE_DOUBLE="\"([^\"]*)\""
		if [[ $line =~ $RE || $line =~ $RE_DOUBLE ]]; then
			PODSPEC_NAME=${BASH_REMATCH[1]}
			echo_success "podspec名称为 ${PODSPEC_NAME}"
		fi
    	break
    fi
done < $PODSPEC_PATH

log_line

# ======================================== 匹配podspec文件中的tag号 ===============================
# 1.0.0 这种版本号
OID_VERSION=''
NEW_VERSION=''

# 真正写在文件中的版本号的那一整行文本内容
OID_TMP_STRING=''
NEW_TMP_STRING=''

# 逐行匹配获取文件中的版本号
while read line
do
    # echo $line
    if [[ $line == s.version* ]]; then
    	# echo $line
    	# 匹配单引号或者双引号
		RE="\'([^\']*)\'"
		RE_DOUBLE="\"([^\"]*)\""
		if [[ $line =~ $RE || $line =~ $RE_DOUBLE ]]; then
			OID_VERSION="${BASH_REMATCH[1]}"
			echo_success "podspec当前版本号 $OID_VERSION"
			OID_TMP_STRING=$line
		fi
    	break
    fi
done < $PODSPEC_PATH

log_line

echo_success "组件仓库最后一次提交的标签版本号是 $(git describe --tags `git rev-list --tags --max-count=1`)"

log_line

# ======================================== 设置版本号(如果未手动设置, 会自动计算) ===============================
read -p "输入需要设置的版本号: " parameter
NEW_VERSION="$parameter"

if [[ ${#NEW_VERSION} == 0 ]]; 
then
	# 版本号未设置, 自动设置tag, 调用计算函数, 
	auto_tag ${OID_VERSION}
	NEW_VERSION=$AUTO_TAG
	echo_success "版本号未输入, tag使用自动计算结果为${NEW_VERSION}"
	NEW_TMP_STRING=${OID_TMP_STRING/$OID_VERSION/$NEW_VERSION}
else

	NEW_TMP_STRING=${OID_TMP_STRING/$OID_VERSION/$NEW_VERSION}
fi

# tag是否相同
IS_VERSION_UPDATE=true
if [ "$NEW_VERSION" != "$OID_VERSION" ]
then
	# 将输入的版本号整合成podspec文件中的一行文字 并且整行修改进去
	sed -i '' "s/${OID_TMP_STRING}/${NEW_TMP_STRING}/g" $PODSPEC_PATH
	echo_success "原版本号${OID_VERSION} 修改后的版本号${NEW_VERSION}"
	IS_VERSION_UPDATE=true
else
	IS_VERSION_UPDATE=false
fi

SECONDS=0

# ======================================== 提交改动文件到组件仓库并设置tag ===============================
if [[ $IS_VERSION_UPDATE == true ]]
then
	# 所有修改的文件全量提交
	git add .
	echo "====正在提交tag===="
	git commit -m "tag :${NEW_VERSION}"
	git tag -a ${NEW_VERSION} -m "${NEW_VERSION}"
	git push --tags

	if [ "$?" -ne 0 ]
	then
		# git push 失败
		echo_warning "git push tag 失败, 退出脚本中..."
		exit 1;
	fi
	echo "====tag提交完成===="
	log_line
fi

# ======================================== podspec push 到 私有库的Repo Spec ===============================
COCOAPODS_PATH=~/.cocoapods/repos/
REPO_NAME=
# 是否设置默认推送仓库目录
IS_EXISTS_DEFAULT_REPO=false

# 判断是否设置了默认推送仓库目录名, 并且目录名是真实存在
if [ ${#DEFAULT_REPO_DIR_NAME} != 0 ] && [ -d "${COCOAPODS_PATH}${DEFAULT_REPO_DIR_NAME}" ] ; then
	IS_EXISTS_DEFAULT_REPO=true
fi

#处理Space文件目录(如果没有默认,则遍历~/.cocoapods/repo供选择)
if [[ $IS_EXISTS_DEFAULT_REPO == false ]]
then
	# 默认忽略cocoapods的公有文件夹
	echo_success "检索到以下文件夹, 请选择需要推送的私有库Spec目录"
	REPO_DIR_PATH=
	ALL_REPO_DIR_NAME=()
	for dir in $(ls $COCOAPODS_PATH)
	do
	    # [ -d $dir ] && echo $dir
	    REPO_DIR_PATH=${COCOAPODS_PATH}${dir}
	    if [ -d $REPO_DIR_PATH ]
		then
	        ALL_REPO_DIR_NAME+=($dir)
	        echo ${#ALL_REPO_DIR_NAME[*]}. $dir
	    fi
	done 

	# read -p "输入需要Push到的文件夹编号: " REPO_INDEX
	circle_input "输入需要Push到的文件目录编号: "

	REPO_INDEX=`expr $INPUT_NUMBER - 1`
	INPUT_NUMBER=
	REPO_NAME=${ALL_REPO_DIR_NAME[${REPO_INDEX}]}
else
	REPO_NAME=$DEFAULT_REPO_DIR_NAME
	
fi

if [ -z ${REPO_NAME} ]
then
	echo_warning "未读取到CocoaPods 私有 Spec目录, 请检查后重试; 脚本退出中..."
	exit 1;
fi

echo_success "读取到push repo目录: (${REPO_NAME}), 正在验证中..."

# 验证Spec文件正确性
pod spec lint ${PODSPEC_PATH} ${PUSH_REPO_SOURCE} --allow-warnings --verbose --use-libraries

if [ "$?" -ne 0 ] 
then
	echo_warning "${PODSPEC_PATH} 验证失败, 请检查后重试..."
	exit 1;
fi

echo_success "${PODSPEC_PATH} 验证通过, 提交到远程仓库中..."

pod repo push ${REPO_NAME} ${PODSPEC_PATH} ${PUSH_REPO_SOURCE} --allow-warnings --verbose --use-libraries

# 判断执行结果
if [ "$?" -ne 0 ]
then
    echo_warning "Pod Push Repo Space 失败, 检查后再次执行脚本..."
	exit 1;
else
	echo_success "Pod Push Repo Space Success"
	echo_success "Time: $(displaysecs ${SECONDS})"
	echo_success "${PODSPEC_NAME} (${BRANCH_NAME}) 组件 ${NEW_VERSION} 版本 已提交到 ${REPO_NAME}"
fi


