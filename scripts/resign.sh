#!/bin/bash

# 加固产物目录
reinforce_dir="reinforce"
# Android 构建工具版本
build_tools_version=""
default_build_tools_version="29.0.3"
# 项目签名文件
sign_jks="kklonlinekey.jks"
# 签名密码
sign_pass="HZmst012kkl"
# 签名别名
sign_alias="key0"
# 签名别名密码
sign_alias_pass="HZmst012kkl"

# 帮助信息
help_msg(){
    echo "Usage: $0 <no give build_tools_version, use default ${default_build_tools_version}>"
}

# 开始重签名
start_resign() {
  if [ ! -d $reinforce_dir ]
  then
    echo "$reinforce_dir no existed"
    exit 1
  else
    echo "$reinforce_dir existed"
    traverse_resign $reinforce_dir
  fi
}

# 递归遍历已加固文件夹
traverse_resign()
{
    if [[ $# -ne 1 ]]
    then
      echo "need filepath"
      exit 1
    fi
    local filepath=$1
    file_list=$(ls "$filepath")
    for file in $file_list
    do
      if [ -d "${filepath}"/"$file" ]
      then
          if [[ $file != '.' && $file != '..' ]]
          then
              traverse_resign "${filepath}"/"$file"
          fi
      else
          check_suffix_resign "${filepath}"/"$file"
      fi
    done
}

# 获取后缀为 _legu.apk 文件 执行重签名
check_suffix_resign()
{
    file=$1
    local legu_apk_name="_legu.apk"
    if [[ ${file} == *${legu_apk_name} ]]
    then
        resign "$file"
    fi
}

# 重签名
resign() {
  if [[ $# -ne 1 ]]
  then
    echo "need unsigned apk"
    exit 1
  fi
  local unsigned_apk=$1
  echo "unsigned_apk = $unsigned_apk"
   unsigned_apk_name_with_suffix=${unsigned_apk##*/}
  local unsigned_apk_name=${unsigned_apk_name_with_suffix%.*}
  local resigned_apk_name=${unsigned_apk_name//"_legu"/"-resigned"}
  echo "build_tools_version = $build_tools_version"
  # Android 构建工具
  local android_build_tools="$HOME"/Library/Android/sdk/build-tools/"$build_tools_version"
  "${android_build_tools}"/zipalign -v 4  "$unsigned_apk" "$reinforce_dir"/zipaligned.apk
  "${android_build_tools}"/apksigner sign --verbose --ks "${sign_jks}" --ks-pass pass:"${sign_pass}" --ks-key-alias "${sign_alias}" --key-pass pass:"$sign_alias_pass" --out "$reinforce_dir"/"$resigned_apk_name".apk "$reinforce_dir"/zipaligned.apk
}

# 主函数
main(){
  # arg judge
  if [[ $# -ne 1 ]]
  then
    build_tools_version="$default_build_tools_version"
    help_msg
  else
    build_tools_version=$1
  fi
  start_resign
}

main "$@"
