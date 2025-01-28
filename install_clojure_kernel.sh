#!/bin/bash

# Install JDK
pip install install-jdk
jdk_version="23"
jdk_path=$(python -c "import os, jdk; print(jdk.install('$jdk_version'))")
export JAVA_HOME="$jdk_path"
echo "JAVA_HOME set to $JAVA_HOME"
java -version

# Install Clojure
curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
chmod +x linux-install.sh
sudo ./linux-install.sh

# Install Clojupyter
git clone https://github.com/clojupyter/clojupyter.git
cd clojupyter || exit

# Build the standalone jar
env clojure -T:build uber

# Replace the version with the jar file in the target directory
jar_file=$(ls target | grep standalone.jar)
clojure -M -m clojupyter.cmdline install --jarfile "target/$jar_file" --ident "${jar_file%.jar}"

# Sanity check
clojure -M -m clojupyter.cmdline list-installs
jupyter-kernelspec list

# Install the tcp IPC reverse proxy
cd ..
wget -qO- https://gist.github.com/SpencerPark/e2732061ad19c1afa4a33a58cb8f18a9/archive/b6cff2bf09b6832344e576ea1e4731f0fb3df10c.tar.gz | tar xvz --strip-components=1
python install_ipc_proxy_kernel.py --kernel="${jar_file%.jar}" --implementation=ipc_proxy_kernel.py

# Update kernel display name
apt-get install -y jq
kernel_dir="/root/.local/share/jupyter/kernels/${jar_file%.jar}"
jq '.display_name = "Clojure IPC"' "$kernel_dir/kernel.json" > /tmp/kernel-modified.json
mv /tmp/kernel-modified.json "$kernel_dir/kernel.json"

# Final checks
ls -al /root/.local/share/jupyter/kernels
cat "$kernel_dir/kernel.json"

echo "Clojure Jupyter kernel setup complete!"
