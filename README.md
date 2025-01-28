# Setting Up Clojupyter on Colab

Follow these steps to install and use Clojupyter in a Google Colab notebook.

## Step 1: Run the Installation Script
In a Colab notebook, execute the following commands in a code cell:

```bash
!wget https://raw.githubusercontent.com/qubit55/clojupyter_colab_setup/refs/heads/main/install_clojure_kernel.sh
!chmod +x install_clojure_kernel.sh
!./install_clojure_kernel.sh
```

This will download and execute the setup script for Clojupyter.

## Step 2: Switch to the Clojure Kernel
Once the installation is complete:
1. Go to **Runtime** -> **Change runtime type**.
2. In the "Runtime type" dropdown, select **Clojure IPC**.
3. Wait for the kernel to initialize. The RAM and disk usage chart in the upper-right corner will confirm when it’s ready.

## Step 3: You're Ready to Go!
Start coding and enjoy using Clojupyter in your Colab notebook.
