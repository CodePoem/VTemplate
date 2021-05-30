#!/bin/bash

# 收集产物目录
artifacts_dir="artifacts"
# 项目release包产物目录
app_release_apk_dir="app/build/outputs/apk/published/release"
# 项目release包mapping目录
app_release_mapping_dir="app/build/outputs/mapping/published/release"
# 加固产物目录
reinforce_dir="reinforce"
# 多渠道产物目录
multi_channel_dir="channels"

copy_artifacts() {
  if [ ! -d $artifacts_dir ]
  then
    mkdir $artifacts_dir
    echo "mkdir dir success"
  else
    echo "mkdir dir already existed"
  fi
  cp -avX $app_release_apk_dir/* $artifacts_dir
  cp -avX $app_release_mapping_dir/* $artifacts_dir
  cp -avX $reinforce_dir/* $artifacts_dir
  cp -avX $multi_channel_dir/* $artifacts_dir
}

# 主函数
main(){
  copy_artifacts
}

main "$@"
