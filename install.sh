#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")"
BASE_DIR="$(pwd)"
PACKAGES=(aria2 git unzip wget)
# Tensorflow states 3.4.0 as the minimum version.
# This is also the minimum version with venv support.
# 3.7.0 and up only includes tensorflow 2.0 and not 1.15
MIN_PYTHON_VERS="3.4.0"
MAX_PYTHON_VERS="3.6.9"

version_check () {
	MAX_VERS=$(echo -e "$(python3 --version | cut -d' ' -f2)\n$MAX_PYTHON_VERS\n$MIN_PYTHON_VERS"\
	| sort -V | tail -n1)
	MIN_VERS=$(echo -e "$(python3 --version | cut -d' ' -f2)\n$MAX_PYTHON_VERS\n$MIN_PYTHON_VERS"\
	| sort -V | head -n1)
	if [ "$MIN_VERS" != "$MIN_PYTHON_VERS" ]; then
		echo "Your installed python version, $(python3 --version), is too old."
		echo "Please update to at least $MIN_PYTHON_VERS."
		exit 1
	elif [ "$MAX_VERS" != "$MAX_PYTHON_VERS" ]; then
		echo "Your installed python version, $(python3 --version), is too new."
		echo "Please install $MAX_PYTHON_VERS."
		exit 1
	fi
}

pip_install () {
	if [ ! -d "./venv" ]; then
		# Some distros have venv built into python so this isn't always needed.
		if is_command 'apt-get'; then
			apt-get install python3-venv
		fi
		python3 -m venv ./venv
	fi
	source "${BASE_DIR}/venv/bin/activate"
	pip install --upgrade pip setuptools
	pip install -r "${BASE_DIR}/requirements.txt"
}

is_command() {
	command -v "${@}" > /dev/null
}

system_package_install() {
	PACKAGES=(aria2 git unzip wget)
	if is_command 'apt-get'; then
		sudo apt-get install ${PACKAGES[@]}
	elif is_command 'brew'; then
		brew install ${PACKAGES[@]}
	elif is_command 'yum'; then
		sudo yum install ${PACKAGES[@]}
	elif is_command 'dnf'; then
		sudo dnf install ${PACKAGES[@]}
	elif is_command 'pacman'; then
		sudo pacman -S ${PACKAGES[@]}
	elif is_command 'apk'; then
		sudo apk --update add ${PACKAGES[@]}
	else
		echo "You do not seem to be using a supported package manager."
		echo "Please make sure ${PACKAGES[@]} are installed then press [ENTER]"
		read NOT_USED
	fi
}

install_aid () {
	version_check
	pip_install
	system_package_install
}

install_aid

BASE_DIR="$(pwd)"
MODELS_DIRECTORY=generator/gpt2/models
MODEL_VERSION=model_v5

MODEL_DIRECTORY="${MODELS_DIRECTORY}"

MODEL_NAME=model-550
MODEL_TORRENT_URL="https://github.com/AIDungeon/AIDungeon/files/3935881/model_v5.torrent.zip"
MODEL_TORRENT_BASENAME="$(basename "${MODEL_TORRENT_URL}")"

download_torrent() {
  echo "Creating directories."
  mkdir -p "${MODEL_DIRECTORY}"
  cd "${MODEL_DIRECTORY}"
  wget "${MODEL_TORRENT_URL}"
  unzip "${MODEL_TORRENT_BASENAME}"
  which aria2c > /dev/null
  if [ $? == 0 ]; then
    echo -e "\n\n==========================================="
    echo "We are now starting to download the model."
    echo "It will take a while to get up to speed."
    echo "DHT errors are normal."
    echo -e "===========================================\n"
    aria2c \
      --max-connection-per-server 16 \
      --split 64 \
      --bt-max-peers 500 \
      --seed-time=0 \
      --summary-interval=15 \
      --disable-ipv6 \
      "${MODEL_TORRENT_BASENAME%.*}"
    echo "Download Complete!"
    fi
}

redownload () {
	echo "Deleting $MODEL_DIRECTORY"
	rm -rf ${MODEL_DIRECTORY}
	download_torrent
}

if [[ -d "${MODEL_DIRECTORY}" ]]; then
	ANSWER="n"
	echo "AIDungeon2 Model appears to be downloaded."
	echo "Would you like to redownload?"
	echo "WARNING: This will remove the current model![y/N]"
	read ANSWER
	ANSWER=$(echo $ANSWER | tr '[:upper:]' '[:lower:]')
	case $ANSWER in
		 [yY][eE][sS]|[yY])
			redownload;;
		*)
			echo "Exiting program!"
			exit;;
	esac
else
	download_torrent
fi

