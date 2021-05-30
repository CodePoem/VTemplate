#!/bin/bash

# 加固产物目录
reinforce_dir="reinforce"
# 多渠道产物目录
multi_channel_dir="channels"
# 多渠道渠道信息文件
multi_channel_file="app/channel.txt"
# 多渠道jar包文件
multi_channel_jar="jar/walle-cli-all.jar"

# 递归遍历已加固文件夹
traverse_multi_channel()
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
              traverse_dir "${filepath}"/"$file"
          fi
      else
          check_suffix_multi_channel "${filepath}"/"$file"
      fi
    done
}

# 获取后缀为 -resigned.apk 文件 执行多渠道
check_suffix_multi_channel()
{
    file=$1
    local resigned_apk_name="-resigned.apk"
    if [[ ${file} == *${resigned_apk_name} ]]
    then
        multi_channel "$file"
    fi
}

# 多渠道
multi_channel() {
  if [[ $# -ne 1 ]]
  then
    echo "need signed apk"
    exit 1
  fi
  local signed_apk=$1
  echo "signed_apk = $signed_apk"
  java -jar "${multi_channel_jar}" batch -f "${multi_channel_file}" "${signed_apk}" "${multi_channel_dir}"
}

# 主函数
main(){
  traverse_multi_channel $reinforce_dir
}

main "$@"
