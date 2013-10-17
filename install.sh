#!/bin/bash
#
# jmeter-ec2 - Install Script (Runs on remote ec2 server)
#


REMOTE_HOME=$1
INSTALL_JAVA=$2
JMETER_VERSION=$3
PLUGINS=( "http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.1.1.zip" "http://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-1.1.1.zip" )


function install_jmeter_plugins() {

    sudo apt-get install unzip
    
    for plugin in ${PLUGINS[@]}; do
        echo "downloading and installing plugin from $plugin"
        mkdir -p "$REMOTE_HOME/plugindl"
        wget -q -O $REMOTE_HOME/plugindl/plugin.zip $plugin
        unzip -o $REMOTE_HOME/plugindl/plugin.zip -d $REMOTE_HOME/plugindl/extract
        cp -f -r $REMOTE_HOME/plugindl/extract/lib/* $REMOTE_HOME/$JMETER_VERSION/lib/
        rm -rf  $REMOTE_HOME/plugindl/
    done

}

function install_mysql_driver() {
    wget -q -O $REMOTE_HOME/mysql-connector-java-5.1.16-bin.jar https://s3.amazonaws.com/jmeter-ec2/mysql-connector-java-5.1.16-bin.jar
    mv $REMOTE_HOME/mysql-connector-java-5.1.16-bin.jar $REMOTE_HOME/$JMETER_VERSION/lib/
}


cd $REMOTE_HOME

if [ $INSTALL_JAVA -eq 1 ] ; then
    # install java
	
	#ubuntu
	sudo apt-get update #update apt-get
	sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy install default-jre
	wait

#    bits=`getconf LONG_BIT`
#    if [ $bits -eq 32 ] ; then
#        wget -q -O $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin https://s3.amazonaws.com/jmeter-ec2/jre-6u30-linux-i586-rpm.bin
#        chmod 755 $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin
#        $REMOTE_HOME/jre-6u30-linux-i586-rpm.bin
#    else # 64 bit
#        wget -q -O $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin https://s3.amazonaws.com/jmeter-ec2/jre-6u30-linux-i586-rpm.bin
#        chmod 755 $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin
#        $REMOTE_HOME/jre-6u30-linux-x64-rpm.bin
#    fi

fi

# install jmeter
case "$JMETER_VERSION" in

jakarta-jmeter-2.5.1)
    # JMeter version 2.5.1
    wget -q -O $REMOTE_HOME/$JMETER_VERSION.tgz http://archive.apache.org/dist/jmeter/binaries/$JMETER_VERSION.tgz
    tar -xf $REMOTE_HOME/$JMETER_VERSION.tgz
    # install jmeter-plugins [http://code.google.com/p/jmeter-plugins/]
    install_jmeter_plugins
    # install mysql jdbc driver
	install_mysql_driver
    ;;

apache-jmeter-*)
    # JMeter version 2.x
    wget -q -O $REMOTE_HOME/$JMETER_VERSION.tgz http://archive.apache.org/dist/jmeter/binaries/$JMETER_VERSION.tgz
    tar -xf $REMOTE_HOME/$JMETER_VERSION.tgz
    # install jmeter-plugins [http://code.google.com/p/jmeter-plugins/]
    install_jmeter_plugins
    # install mysql jdbc driver
	install_mysql_driver
    ;;
    
*)
    echo "Please check the value of JMETER_VERSION in the properties file, $JMETER_VERSION is not recognised."
esac

echo "software installed"
