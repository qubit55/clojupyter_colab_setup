#!/bin/bash

set -e

# Parse optional arguments
JDK_VERSION="23"
while getopts "j:" opt; do
  case $opt in
    j)
      JDK_VERSION="$OPTARG" ;;
    *)
      echo "Usage: $0 [-j jdk_version]" >&2
      exit 1 ;;
  esac
done

# Install JDK
pip install install-jdk

# Install specified JDK version
jdk_path=$(python -c "import jdk; print(jdk.install('$JDK_VERSION'))")
export JAVA_HOME="$jdk_path"
echo "JAVA_HOME is set to $JAVA_HOME"
java -version

# Install Clojure
curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
chmod +x linux-install.sh
sudo ./linux-install.sh

# Get the installed Clojure version
clojure_version=$(clojure -Sdescribe | grep '"version":' | sed -E 's/.*"version": "([^"]+)".*/\1/')

# Clone and build Clojupyter
if [ -d "clojupyter" ]; then
  echo "Directory 'clojupyter' already exists. Removing it to avoid conflicts."
  rm -rf clojupyter
fi

git clone https://github.com/clojupyter/clojupyter.git
cd clojupyter

env clojure -T:build uber

# Get the generated jar file and version
jar_file=$(ls target | grep standalone.jar)
kernel_version=$(echo "$jar_file" | sed -E 's/^clojupyter-(.*)-standalone\.jar$/\1/')

# Adjust kernel directory name to exclude SNAPSHOT
kernel_ident=$(echo "$kernel_version" | sed -E 's/-SNAPSHOT//')

# Install the kernel
clojure -M -m clojupyter.cmdline install --jarfile target/$jar_file --ident clojupyter-$kernel_ident

# Verify kernel installation
clojure -M -m clojupyter.cmdline list-installs
jupyter-kernelspec list

# Install the IPC reverse proxy
cd ..
wget -qO- https://gist.github.com/SpencerPark/e2732061ad19c1afa4a33a58cb8f18a9/archive/b6cff2bf09b6832344e576ea1e4731f0fb3df10c.tar.gz | tar xvz --strip-components=1
python install_ipc_proxy_kernel.py --kernel="clojupyter-$kernel_ident" --implementation=ipc_proxy_kernel.py

# Install jq for modifying kernel.json
apt-get update && apt-get install -y jq

# Modify the kernel display name
kernel_json_path="/root/.local/share/jupyter/kernels/clojupyter-$kernel_ident/kernel.json"
kernel_display_name="Clojure IPC $clojure_version"
jq --arg name "$kernel_display_name" '.display_name = $name' "$kernel_json_path" > /tmp/kernel-modified.json && mv /tmp/kernel-modified.json "$kernel_json_path"

# List installed kernels
ls -al /root/.local/share/jupyter/kernels

# Display the modified kernel.json
cat "$kernel_json_path"

echo "Clojure Jupyter kernel installation is complete!"
