#!/bin/sh
# All variables is in env.sh file
DEMO="EAP + JDG for Http Session Offload"
AUTHORS="Rafael T. C. Soares"
PROJECT="git@github.com:rafaeltuelho/eap-jdg-httpsession-offload-demo.git"
PRODUCT="JBoss EAP and JDG"

. env.sh

# wipe screen.
clear

echo
echo "#################################################################"
echo "##                                                             ##"
echo "##  Setting up the ${DEMO}          ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "## #######    #    ######                    # ######   #####  ##"
echo "## #         # #   #     #      #            # #     # #     # ##"
echo "## #        #   #  #     #      #            # #     # #       ##"
echo "## #####   #     # ######     #####          # #     # #  #### ##"
echo "## #       ####### #            #      #     # #     # #     # ##"
echo "## #       #     # #            #      #     # #     # #     # ##"
echo "## ####### #     # #                    #####  ######   #####  ##"
echo "##                                                             ##"
echo "##                                                             ##"
echo "##  brought to you by,                                         ##"
echo "##             ${AUTHORS}                             ##"
echo "##                                                             ##"
echo "##  ${PROJECT} ##"
echo "##                                                             ##"
echo "#################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed or not present in thet system PATH yet... aborting."; exit 1; }

# make some checks first before proceeding.
if [ -r $SRC_EAP_DIR/$EAP ] || [ -L $SRC_EAP_DIR/$EAP ]; then
	printf "\n EAP installer is present..."
else
	printf "\n Need to download $EAP package from the Customer Portal"
	printf "\n\t and place it in the $SRC_EAP_DIR directory to proceed... \n"
	exit
fi

if [ -r $SRC_JDG_DIR/$JDG ] || [ -L $SRC_JDG_DIR/$JDG ]; then
		printf "\n JDG installer is present..."
else
		printf "\n Need to download $JDG installer from the Customer Portal"
		printf "\n\t and place it in the $SRC_JDG_DIR directory to proceed... \n"
		exit
fi

# Remove the old JBoss instance, if it exists.
if [ -x $TARGET_DIR/. ]; then
	printf "\n  - removing existing demo installation... \n"
	rm -rf $TARGET_DIR/*
fi

#read

# Run installers.
printf "\n JBoss EAP installer running now..."
if [ ${EAP: -4} == ".jar" ]; then
	java -jar $SRC_EAP_DIR/$EAP $SUPPORT_DIR/installation-eap -variablefile $SUPPORT_DIR/installation-eap.variables
else
	unzip -q $SRC_EAP_DIR/$EAP -d $TARGET_DIR/ &&
	sh $JBOSS_HOME/bin/add-user.sh -s admin jbosseap1!
fi

if [ $? -ne 0 ]; then
	printf "\n Error occurred during JBoss EAP installation!"
	exit
fi

printf "\n JBoss JDG installer running now... \n"
unzip -q $SRC_JDG_DIR/$JDG -d $TARGET_DIR/

if [ $? -ne 0 ]; then
	printf "\n Error occurred during $PRODUCT installation \n"
	exit
fi

#echo
#echo "JBoss JDG patch ($PATCH) installation now..."
#echo
#unzip $SRC_JDG_DIR/$PATCH -d ./target
#cd $PATCH_DIR
#./apply-updates.sh ../jboss-eap-6.4 eap6.x
#cd ../..
#rm -rf $PATCH_DIR

# Add execute permissions to the standalone.sh script.
printf "\t - making sure all server scripts are executable... \n"

chmod u+x $JBOSS_HOME/bin/*.sh
chmod u+x $JDG_HOME/bin/*.sh

printf "\n Cloning the EAP standlone server base into eap_node1 and eap_node2"
cp -r $EAP_BASE_SERVER_DIR $JBOSS_HOME/eap_node1
cp -r $EAP_BASE_SERVER_DIR $JBOSS_HOME/eap_node2

printf "\n\t  - EAP: setting up standalone-ha.xml configuration adjustments... \n"
cp $SUPPORT_DIR/standalone-ha.xml $JBOSS_HOME/eap_node1/configuration/
cp $SUPPORT_DIR/standalone-ha.xml $JBOSS_HOME/eap_node2/configuration/

printf "\n Building the Payment CDI Event web application. \n"
cd $PRJ_DIR
mvn clean install

printf "\n Deploying the Payment CDI Event web application. \n"

cp target/jboss-payment-cdi-event.war ../../$JBOSS_HOME/eap_node1/deployments/jboss-payment-cdi-event.war
touch ../../$JBOSS_HOME/eap_node1/deployments/jboss-payment-cdi-event.war.dodeploy
cp target/jboss-payment-cdi-event.war ../../$JBOSS_HOME/eap_node2/deployments/jboss-payment-cdi-event.war
touch ../../$JBOSS_HOME/eap_node2/deployments/jboss-payment-cdi-event.war.dodeploy
cd ../..

printf "\n Now you need to start the cluster."
printf "\n\t Use the script ./servers.sh start all"

printf "\n\n $PRODUCT $VERSION $DEMO Setup Complete. \n"
