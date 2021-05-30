#!/bin/bash

# 乐固jar包文件
legu_jar="jar/ms-shield.jar"
# 乐固 sid
legu_sid=AKID0tX4LMXl8QTIyQKXDe1UgbGfogofnciZ
# 乐固 skey
legu_skey=qkQr41jBxU9by6yaw4vmOs75qKZYWEn6
# 项目release包产物目录
app_release_dir="app/build/outputs/apk/published/release"
# 加固产物目录
reinforce_dir="reinforce"

# 加固
reinforce() {
  if [ ! -d $reinforce_dir ]
  then
    mkdir $reinforce_dir
    echo "mkdir dir success"
  else
    echo "mkdir dir already existed"
  fi
  traverse_reinforce $app_release_dir
}

# 遍历待加固文件夹
traverse_reinforce() {
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
              traverse_reinforce "${filepath}"/"$file"
          fi
      else
          check_suffix_reinforce "${filepath}"/"$file"
      fi
    done
}

# 获取后缀为 apk 文件 执行加固
check_suffix_reinforce()
{
    file=$1
    if [[ "${file##*.}"x = "apk"x ]]
    then
        legu "$file"
    fi
}

# 乐固加固
legu() {
  if [[ $# -ne 1 ]]
  then
    echo "need upload_apk"
    exit 1
  fi
  local upload_apk=$1
  echo "upload_apk = $upload_apk"
  java -Dfile.encoding=utf-8 -jar "${legu_jar}" -sid $legu_sid -skey $legu_skey -uploadPath "$upload_apk" -downloadPath $reinforce_dir
}

# 主函数
main(){
  reinforce
}

main "$@"
