#!/bin/bash

# 更新文件路径
update_file_path=""

# 更新表达式
update_expression=""

# 帮助信息
help_msg_update_file_path(){
    echo "Usage: $0 <need update file path>"
}

help_msg_update_expression(){
    echo "Usage: $0 <need update expression>"
}

# 更新
start_update() {
  if [[ `uname` == 'Darwin' ]]
  then
    echo "Mac OS"
    sed -i '' $update_expression $update_file_path
  elif [[ `uname` == 'Linux' ]]
  then
      echo "Linux"
      sed -i $update_expression $update_file_path
  fi
}

# 主函数
main(){
  # arg judge
  #逐个接收选项及其参数
  while getopts "f:e:" arg
  do
    case "$arg" in
    f)
      echo "f,,:$OPTARG"
      update_file_path=$OPTARG
      ;;
    e)
      echo "e,,:$OPTARG"
      update_expression=$OPTARG
      ;;
    ?)
      echo "there is unrecognized parameter."
      exit 1
      ;;
    esac
  done
  start_update
}

main "$@"
