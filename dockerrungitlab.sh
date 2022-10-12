#!/bin/bash
###################################################################
info(){
  echo -e "\033[35m 【`hostname` `date '+%Y-%m-%d %H:%M:%S'`】\033[0m" "\033[36m$1\033[0m "
}
info1(){
  echo -e "\033[36m $1 \033[0m "
}
info5(){
 info1 "==============================================================================" 
}
info9(){
  echo -e "\033[32m 【`hostname` `date '+%Y-%m-%d %H:%M:%S'`】\033[0m" "\033[36m$1\033[0m "
}
info8(){
  echo -e "\033[31m 【`hostname` `date '+%Y-%m-%d %H:%M:%S'`】\033[0m" "\033[35m$1\033[0m "
}
info6(){
  echo -e "\033[33m 【`hostname` `date '+%Y-%m-%d %H:%M:%S'`】\033[0m" "\033[91m$1\033[0m "
}
info7(){
  echo -e "\033[35m 【`hostname` `date '+%Y-%m-%d %H:%M:%S'`】\033[0m" "\033[32m$1\033[0m "
}
###################################################################

gitlab_run(){
[ ! -d /opt/gitlab ] && mkdir ${GITLAB_HOME}
docker run -d --detach \
  --env GITLAB_OMNIBUS_CONFIG="external_url ${GITLAB_url}; gitlab_rails['lfs_enabled'] = true; nginx['listen_port'] = ${GITLAB_port}" \
  -p ${gitlab_port}:80 \
  --name gitlab \
  --restart always \
  --volume $gitlab_home/config:/etc/gitlab \
  --volume $gitlab_home/logs:/var/log/gitlab \
  --volume $gitlab_home/data:/var/opt/gitlab \
  ${gitlab_version} >/dev/null
  [ $? -eq 0 ] && info9 "${gitlab_name}启动成功,请等待10s后访问web界面" && info5
}

start_gitlab(){
  local name="gitlab"  GITLAB_HOME="/opt/gitlab" GITLAB_port="80" GITLAB_url="`hostname -i`" 
  info5
  read -p "请输入${name}数据持久化存储目录(默认设置：${GITLAB_HOME}):" gitlab_home
  read -p "请输入${name}容器启动的容器名称(默认设置：${name}):" gitlab_name
  read -p "请输入${name}容器启动的容器端口(默认设置：${GITLAB_port}):" gitlab_port
  read -p "请输入${name}容器启动的镜像版本(默认设置：gitlab/gitlab-ce:11.10.4-ce.0):" gitlab_version
  read -p "请输入${name}容器启动时${name}访问的URL(主机ip地址：${GITLAB_url}):" GITLAB_url
  gitlab_version=${gitlab_version:-gitlab/gitlab-ce:11.10.4-ce.0}
  gitlab_name=${gitlab_name:-gitlab}
  gitlab_port=${gitlab_port:-80}
  gitlab_home=${gitlab_home:-/opt/gitlab}
  GITLAB_url=${GITLAB_url}
  if [ -z ${gitlab_version} ] && [ -z ${gitlab_name} ] && [ -z ${gitlab_port} ]&& [ -z ${gitlab_home} ];then
   info8 "请根据提示,输入所有的值"
   exit 0
 else
 read -p "选择${gitlab_name}的启动方式:(run|restart|start|stop|rm|status):" gitlab_start_run1
 if [ -z ${gitlab_start_run1} ];then
       info6 "请重新输入"    
       ./dockerrungitlab.sh
 else
   case $gitlab_start_run1 in
     'run')
         if [ `docker images | grep gitlab|wc -l` -eq 0 ];then
           info7 "start pull ${gitlab_version}, wait !!!!"
            docker pull ${gitlab_version}  >/dev/null
          fi
         gitlab_run;;
     'status')
	 if [ `docker ps | grep ${gitlab_name} |wc -l` -eq 0 ];then
	   info " ${gitlab_name} Unrunning successful"
         else
	   docker ps |grep  ${gitlab_name}
	 fi
	 info5;;
     'restart')
	 if [ `docker ps | grep ${gitlab_name} |wc -l` -eq 0 ];then
           info8 "首次使用，请选择run启动容器"
         else
           docker restart ${gitlab_name} &>/dev/null
           [ $? -eq 0 ] && info " ${gitlab_name} Restart successful"
	 fi
	 info5;;
     'start')
	 if [ `docker ps | grep ${gitlab_name} |wc -l` -eq 0 ];then
           info8 "首次使用，请选择run启动容器"
         else
            docker start ${gitlab_name} &>/dev/null
            [ $? -eq 0 ] &&  info " ${gitlab_name} Start successful"
	 fi
	 info5;;
     'stop')
	 if [ `docker ps | grep ${gitlab_name} |wc -l` -eq 0 ];then
           info8 "首次使用，请选择run启动容器"
         else
           docker stop ${gitlab_name} &>/dev/null
           [ $? -eq 0 ] &&   info " ${gitlab_name} Stop successful"
	 fi
	 info5;;
     'rm')
           docker rm -f ${gitlab_name} &>/dev/null
           [ $? -eq 0 ] &&  info " ${gitlab_name} delete successful" && info5;;
      '*')   
              info "脚本执行错误,请检查后继续";;
   esac
  fi
 fi
}
start_gitlab
