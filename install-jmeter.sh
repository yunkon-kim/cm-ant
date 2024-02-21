#!/bin/bash
PROJECT_ROOT=$(pwd)
JMETER_WORKING_DIR="./third_party/jmeter"
JMETER_VERSION="apache-jmeter-5.3"
JMETER_INSTALL_URL="https://archive.apache.org/dist/jmeter/binaries/$JMETER_VERSION.tgz"
JMETER_BIN="$JMETER_VERSION/bin"

# base setup
mkdir $JMETER_WORKING_DIR
cd $JMETER_WORKING_DIR

# install need tools
apt-get install -y wget default-jdk

unzip_jmeter() {
    tar xzvf "$JMETER_VERSION.tgz" && rm "$JMETER_VERSION.tgz"
    rm -rf "$JMETER_VERSION/docs" "$JMETER_VERSION/printable_docs"
}

# install jmeter
if [ -d "$JMETER_VERSION" ]; then
    echo "[CB-ANT] Jmeter is already installed."
elif [ -f "$JMETER_VERSION.tgz" ]; then 
    echo "[CB-ANT] Jmeter gzip file is installed on $JMETER_WORKING_DIR. Let's do remaining installation."
    unzip_jmeter
else
    echo "[CB-ANT] JMeter is installing on path $JMETER_WORKING_DIR"
    wget $JMETER_INSTALL_URL
    unzip_jmeter
fi


# install cmd runner
CMD_RUNNER_VERSION="2.2.1"
CMD_RUNNER_JAR="cmdrunner-$CMD_RUNNER_VERSION.jar"

if [ ! -e "$CMD_RUNNER_JAR" ]; then 
    wget "https://repo1.maven.org/maven2/kg/apc/cmdrunner/$CMD_RUNNER_VERSION/$CMD_RUNNER_JAR"
    
    echo "[CB-ANT] Installed cmd runner."
fi


# install plugin manager
PLUGIN_MANAGER_VERSION="1.6"
PLUGIN_MANAGER_JAR="jmeter-plugins-manager-$PLUGIN_MANAGER_VERSION.jar"

if [ ! -e "$PLUGIN_MANAGER_JAR" ]; then 
    wget "https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/$PLUGIN_MANAGER_VERSION/$PLUGIN_MANAGER_JAR"
    
    echo "[CB-ANT] Installed plugin manager."
fi

cp $CMD_RUNNER_JAR "$JMETER_VERSION/lib/"
cp $PLUGIN_MANAGER_JAR "$JMETER_VERSION/lib/ext/"

# install perfmon plugin
java -jar "$JMETER_VERSION/lib/$CMD_RUNNER_JAR" --tool org.jmeterplugins.repository.PluginManagerCMD install jpgc-perfmon,jpgc-dummy
echo "[CB-ANT] Installed plugin perfmon."

export PATH="$PATH:$JMETER_BIN"
alias jmeter="$JMETER_BIN/jmeter"
jmeter --version

cd $PROJECT_ROOT  # move to project root
echo "[CB-ANT] Jmeter is completely installed!!"