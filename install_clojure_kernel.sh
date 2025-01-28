#!/bin/bash

# Exit script on error
set -e

# Install JDK
pip install install-jdk

# Set up and install JDK 23
jdk_version="23"
python -c "import jdk; jdk.install('$jdk_version')"
export JAVA_HOME="/root/.jdk/jdk-23.0.1+11"
echo "JAVA_HOME is set to: $JAVA_HOME"
java -version

# Install Clojure
curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
chmod +x linux-install.sh
sudo ./linux-install.sh

# Clone and build Clojupyter repository
git clone https://github.com/clojupyter/clojupyter.git
cd clojupyter
# Build the standalone jar using clojure
env clojure -T:build uber

# Substitute the generated jar file version dynamically
jar_file=$(find target -name "clojupyter-*-standalone.jar" | head -n 1)
echo "Using JAR file: $jar_file"

# Install the Clojupyter kernel using the jar file
clojure -M -m clojupyter.cmdline install --jarfile "$jar_file" --ident "clojupyter"

# Verify installations
clojure -M -m clojupyter.cmdline list-installs
jupyter-kernelspec list

# Install the TCP IPC reverse proxy
wget -qO- https://gist.github.com/SpencerPark/e2732061ad19c1afa4a33a58cb8f18a9/archive/b6cff2bf09b6832344e576ea1e4731f0fb3df10c.tar.gz | tar xvz --strip-components=1
python install_ipc_proxy_kernel.py --kernel="clojupyter" --implementation=ipc_proxy_kernel.py

# Rename the new kernel display name for clarity
apt-get install -y jq
kernel_json="/root/.local/share/jupyter/kernels/clojupyter/kernel.json"
jq '.display_name = "Clojure IPC"' "$kernel_json" > /tmp/kernel-modified.json && mv /tmp/kernel-modified.json "$kernel_json"

# List and display the kernel directory for verification
ls -al /root/.local/share/jupyter/kernels

# Display the updated kernel.json file
cat "$kernel_json"

# Print completion message
echo "Clojure kernel setup complete."
