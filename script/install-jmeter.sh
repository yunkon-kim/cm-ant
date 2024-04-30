#!/bin/bash

echo "[CM-ANT] JMeter Installation"
set -e

# Base setup
JMETER_WORK_DIR=${JMETER_WORK_DIR:="${HOME}/jmeter"}
JMETER_VERSION=${JMETER_VERSION:="5.3"}
JMETER_FOLDER="apache-jmeter-${JMETER_VERSION}"
JMETER_FULL_PATH="${JMETER_WORK_DIR}/${JMETER_FOLDER}"
JMETER_INSTALL_URL="https://archive.apache.org/dist/jmeter/binaries/${JMETER_FOLDER}.tgz"

echo "This is jmeter working directory >>>>>>>>>>>>>>>>> ${JMETER_WORK_DIR}"
echo "This is jmeter folder name >>>>>>>>>>>>>>>>>>>>>>> ${JMETER_FOLDER}"

echo ""
echo ""
echo ""
echo ""
echo ""

mkdir -p "${JMETER_WORK_DIR}"
mkdir -p "${JMETER_WORK_DIR}/result"
mkdir -p "${JMETER_WORK_DIR}/test_plan"

echo "[CM-ANT] [Step 1/6] Installing default required tools..."
sudo apt-get update -y | sudo apt-get install -y wget default-jre

unzip_jmeter() {
  sudo tar -xf "${JMETER_FULL_PATH}.tgz" -C "${JMETER_WORK_DIR}" && sudo rm "${JMETER_FULL_PATH}.tgz"
  sudo rm -rf "${JMETER_FULL_PATH}/docs" "${JMETER_FULL_PATH}/printable_docs"
}


echo ""
echo ""
echo ""
echo ""
echo ""


echo "[CM-ANT] [Step 2/6] Downloading and Extracting Apache JMeter..."
if [ -d "${JMETER_FULL_PATH}" ]; then
  echo "[CM-ANT] Jmeter is already installed."
elif [ -f "${JMETER_FULL_PATH}.tgz" ]; then
  echo "[CM-ANT] Jmeter gzip file is installed on ${JMETER_WORK_DIR}. Let's do remaining installation."
  unzip_jmeter
else
  # jmeter is not installed
  echo "[CM-ANT] JMeter is installing on path ${JMETER_WORK_DIR}"
  sudo wget "${JMETER_INSTALL_URL}" -P "${JMETER_WORK_DIR}"
  unzip_jmeter
fi

# give permission to user
sudo chmod -R 777 ${JMETER_WORK_DIR}


echo ""
echo ""
echo ""
echo ""
echo ""

# install cmd runner
echo "[CM-ANT] [Step 3/6] Download CMD Runner to install plugins..."
CMD_RUNNER_VERSION="2.2.1"
CMD_RUNNER_JAR="cmdrunner-$CMD_RUNNER_VERSION.jar"

if [ ! -e "$CMD_RUNNER_JAR" ]; then
    wget "https://repo1.maven.org/maven2/kg/apc/cmdrunner/$CMD_RUNNER_VERSION/$CMD_RUNNER_JAR"
    echo "[CB-ANT] Installed cmd runner."
fi


echo ""
echo ""
echo ""
echo ""
echo ""


# install plugin manager
echo "[CM-ANT] [Step 4/6] Download Plugin Manager to manage plugins..."
PLUGIN_MANAGER_VERSION="1.6"
PLUGIN_MANAGER_JAR="jmeter-plugins-manager-$PLUGIN_MANAGER_VERSION.jar"

if [ ! -e "$PLUGIN_MANAGER_JAR" ]; then
    wget "https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/$PLUGIN_MANAGER_VERSION/$PLUGIN_MANAGER_JAR"
    echo "[CB-ANT] Installed plugin manager."
fi

sudo mv $CMD_RUNNER_JAR "$JMETER_FULL_PATH/lib/"
sudo mv $PLUGIN_MANAGER_JAR "$JMETER_FULL_PATH/lib/ext/"

echo ""
echo ""
echo ""
echo ""
echo ""


# install perfmon plugin
echo "[CM-ANT] [Step 5/6] Install required plugins to do load test..."
java -jar "$JMETER_FULL_PATH/lib/$CMD_RUNNER_JAR" --tool org.jmeterplugins.repository.PluginManagerCMD install jpgc-perfmon,jpgc-casutg
echo "[CB-ANT] Installed required plugins."


echo ""
echo ""
echo ""
echo ""
echo ""

echo "[CM-ANT] [Step 6/6] Configuring JMeter..."
sudo chmod +x "${JMETER_FULL_PATH}/bin/jmeter.sh"
"${JMETER_FULL_PATH}"/bin/jmeter.sh --version

echo "[CM-ANT] Jmeter is completely installed on ${JMETER_FULL_PATH}"
