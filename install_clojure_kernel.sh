#!/bin/bash

# Exit script on error
set -e

# Install JDK
pip install install-jdk

# Set up and install JDK 23
# Set up and install JDK 23
# Install JDK 23
jdk_version="23"
python -c "import jdk; jdk.install('$jdk_version')"

# Dynamically detect the installed JDK version
JAVA_HOME=$(ls -d /root/.jdk/jdk-* | head -n 1)
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

# Verify JAVA_HOME and Java version
echo "JAVA_HOME is set to: $JAVA_HOME"
java -version

# Create a symlink
sudo ln -sf "$JAVA_HOME/bin/java" /usr/bin/java
sudo ln -sf "$JAVA_HOME/bin/javac" /usr/bin/javac

curl -L -O https://github.com/clojupyter/clojupyter/releases/download/v0.5.424-SNAPSHOT/clojupyter-0.5.424-SNAPSHOT-standalone.jar
java -cp clojupyter-0.5.424-SNAPSHOT-standalone.jar clojupyter.cmdline install


# Verify installations
java -cp clojupyter-0.5.424-SNAPSHOT-standalone.jar clojupyter.cmdline list-installs

# Install the TCP IPC reverse proxy
wget -qO- https://gist.github.com/SpencerPark/e2732061ad19c1afa4a33a58cb8f18a9/archive/b6cff2bf09b6832344e576ea1e4731f0fb3df10c.tar.gz | tar xvz --strip-components=1
python install_ipc_proxy_kernel.py --kernel="clojupyter-0.5.424-snapshot424" --implementation=ipc_proxy_kernel.py

# Rename the new kernel display name for clarity
apt-get install -y jq
kernel_json="/root/.local/share/jupyter/kernels/clojupyter-0.5.424-snapshot424/kernel.json"
jq '.display_name = "Clojure IPC"' "$kernel_json" > /tmp/kernel-modified.json && mv /tmp/kernel-modified.json "$kernel_json"

# List and display the kernel directory for verification
ls -al /root/.local/share/jupyter/kernels

# Display the updated kernel.json file
cat "$kernel_json"

# Print completion message
echo "Clojure kernel setup complete."
