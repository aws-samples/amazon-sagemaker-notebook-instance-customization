#!/bin/bash

echo "
Setting system-wide JAVA_HOME to enable .ipynb to run pyspark-2.x (from the
conda_python3 kernel), directly on this notebook instance.

- This version of pyspark requires Java-1.8. However, since some time in 2021,
  every .ipynb notebooks will automatically inherit
  os.environ['JAVA_HOME'] == '/home/ec2-user/anaconda3/envs/JupyterSystemEnv',
  and this OpenJDK-11 breaks the pyspark-2.x.

- Note that setting JAVA_HOME in ~/.bashrc is not sufficient, because it affects
  only pyspark scripts or REPL ran from a terminal.
"

echo 'export JAVA_HOME=/usr/lib/jvm/java' | sudo tee -a /etc/profile.d/java.sh
