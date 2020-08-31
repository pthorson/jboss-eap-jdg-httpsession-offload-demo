TARGET_DIR=./target

JBOSS_HOME=$TARGET_DIR/jboss-eap-7.1
EAP_BASE_SERVER_DIR=$JBOSS_HOME/standalone
JDG_HOME=$TARGET_DIR/jboss-datagrid-7.1.0-server
PATH=$MVN_HOMEbin:$PATH

echo $JBOSS_HOME
echo $JDG_HOME

# Allow point to dir where installers are.
SRC_EAP_DIR=./installs
SRC_JDG_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects/payment-cdi-event/

EAP=jboss-eap-7.1.0.zip
JDG=jboss-datagrid-7.1.0-server.zip
VERSION="EAP 7.1 and JDG 7.1"

ports_offset=$1

jdg_hotrod_port=$((11222+$ports_offset))
echo $jdg_hotrod_port

function getPIDforJbossNode(){
 node_name=$1
 ps -e | grep java | awk '{print $1}' \
   | while read pid ; do
	  [ -d /proc/$pid ] || continue
	  cmdln=$(cat /proc/$pid/cmdline | grep -a "jboss.node.name=$node_name")
	  if [ ! "${cmdln}" = "" ]
		then
		  #echo "You are going to kill some process:"
		  #echo "${cmdln}"
		  echo $pid
		  return
	  fi
	done
}
echo $(getPIDforNode jdg_node1)
