# 1. Sample Scripts to Customize SageMaker Notebook Instance

Table of contents:

- [1. Sample Scripts to Customize SageMaker Notebook Instance](#1-sample-scripts-to-customize-sagemaker-notebook-instance)
  - [1.1. Overview](#11-overview)
  - [1.2. Non-exhaustive list of customizations](#12-non-exhaustive-list-of-customizations)
  - [1.3. Installation](#13-installation)
    - [1.3.1. Installation from github](#131-installation-from-github)
    - [1.3.2. Installation from local source](#132-installation-from-local-source)
  - [1.4. Usage](#14-usage)
  - [1.5. Appendix](#15-appendix)
    - [1.5.1. Restart JupyterLab](#151-restart-jupyterlab)
    - [1.5.2. Change terminal font size](#152-change-terminal-font-size)
  - [1.6. Related Projects](#16-related-projects)
  - [1.7. Security](#17-security)
  - [1.8. License](#18-license)

## 1.1. Overview

This repo contains scripts to re-run common tweaks on a fresh (i.e., newly
created or rebooted) SageMaker **classic** notebook instance, to make the
notebook instance a little bit more ergonomic for prolonged usage.

After running these scripts your default command-line terminal will go from this:

<img width="363" alt="before_cli" src="https://user-images.githubusercontent.com/6405428/136099983-74691145-45eb-4d9f-be80-55ca731d2098.png">

To something like this:

<img width="489" alt="after_cli" src="https://user-images.githubusercontent.com/6405428/136099995-301c8b4b-4ae5-4b74-9117-615fce9190a3.png">

Once installed, everytime you access a newly restarted notebook instance, you
just need to perform these three short, simple steps to see and experience the
customizations:

1. open a terminal,
2. run a one-liner command line `~/SageMaker/initsmnb/setup-my-sagemaker.sh`,
3. [restart the Jupyter process](#151-restart-jupyterlab).

By supporting a simple one-liner command line, we hope that you can quickly test
this repo as a *data scientist* (with your notebook instance as all that you
need), rather than as an *infrastructure engineer* which typically works with
more sophisticated automation tools or services.

We hope that you find this repo useful to adopt into your daily work habits.

## 1.2. Non-exhaustive list of customizations

Please note that tweaks marked with **\[Need sudo\]** can only be in-effect when
your notebook instance enables
[root access for notebook users](https://aws.amazon.com/blogs/machine-learning/control-root-access-to-amazon-sagemaker-notebook-instances/).

- Jupyter Lab:
  - Reduce font size on Jupyter Lab
  - **\[Need sudo\]** Terminal defaults to `bash` shell, dark theme, and smaller font.
  - **\[Need sudo\]** In addition to SageMaker's built-in conda environments, Jupyter Lab to also
    auto-scan `/home/ec2-user/SageMaker/envs/` for custom conda environments.

    This allows for a "persistent" conda environment under `/home/ec2-user/SageMaker/envs` that
    survives instance reboot.

    Note that after you create a new custom conda environment, e.g.,
    `conda create --prefix /home/ec2-user/SageMaker/envs/MY_CUSTOM_ENV_NAME python=3.9 ipykernel`
    you may need to [restart JupyterLab](#appendix-restart-jupyterlab) before you can see the
    environment listed as one of the kernels.

- Git:
  - Optionally change committer's name and email, which defaults to `ec2-user`
  - git aliases: `git lol`, `git lola`, `git lolc`, and `git lolac`
  - New repo (i.e., `git init`) defaults to branch `main`
  - **\[Need sudo\]** `nbdime` for notebook-friendly diffs

- Terminal:
  - `bash` shortcuts: `alt-.`, `alt-b`, `alt-d`, and `alt-f` work even when
    connecting from OSX.
  - **\[Need sudo\]** Install command lines: `htop`, `tree`, `dos2unix`,
    `dstat`, `tig`, `ranger` (the CLI file explorer),
    [cookiecutter](https://pypi.org/project/cookiecutter/).
    - `ranger` is configured to use relative line numbers

- ipython run from Jupyter Lab's terminal:
  - shortcuts: `alt-.`, `alt-b`, `alt-d`, and `alt-f` work even when connecting
    from OSX.
  - recolor `o.__class__` from dark blue (nearly invisible on the dark theme) to
    a more sane color.

- Some customizations on `vim`:
  - Notably, change window navigation shortcuts from `ctrl-w-{h,j,k,l}` to
    `ctrl-{h,j,k,l}`.

    Otherwise, `ctrl-w` is used by most browsers on Linux (and Windows?) to
    close a browser tab, which renders windows navigation in `vim` unusable.

  - Other opinionated changes; see `init-vim.sh`.

- **\[Need sudo\]** Optionally mount one or more EFS.

## 1.3. Installation

This step needs to be done **once** on a newly *created* notebook instance.

You can choose to have the installation process automatically download the
necessary files from this repo, provided that your SageMaker classic notebook
instance has the necessary network access to this repo.

Another choice is to bootstrap this repo into your SageMaker classic notebook
instance, then invoke the install script in its local mode.

### 1.3.1. Installation from github

Go to the Jupyter Lab on your SageMaker notebook instance. Open a terminal,
then run this command:

```bash
curl -sfL \
    https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-customization/main/initsmnb/install-initsmnb.sh \
    | bash -s -- --git-user 'First Last' --git-email 'ab@email.abc'
```

Both the `--git--user 'First Last` and `--git-email ab@email.abc` arguments are
optional. If you're happy with SageMaker's preset (which uses `ec2-user` as
the commiter name), you can drop these two arguments from the install command.

If you want to auto-mount one or more EFS, install as follows:

```bash
curl -sfL \
    https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-customization/main/initsmnb/install-initsmnb.sh \
    | bash -s -- \
        --git-user 'First Last' \
        --git-email 'ab@email.abc' \
        --efs 'fs-123,fsap-123,my_efs_01' \
        --efs 'fs-456,fsap-456,my_efs_02'
```

All mount points will live under `/home/ec2-user/mnt/`. Thus, the above example
will install a script that can mount two EFS, the first one `fs-123` will be
mounted as `/home/ec2-user/mnt/my_efs_01/`, while the second one `fs-456` will
be mounted as `/home/ec2-user/mnt/my_efs_02/`.

After the installation step finishes, you should see a new directory created: `/home/ec2-user/SageMaker/initsmnb/`.
Your next step is to jump to section [Usage](#14-usage).

### 1.3.2. Installation from local source

On your SageMaker notebook instance, open a terminal and run these commands:

```bash
cd ~/SageMaker
git clone https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization.git
cd amazon-sagemaker-notebook-instance-customization/initsmnb
./install-initsmnb.sh --from-local --git-user 'First Last' --git-email 'ab@email.abc'
```

After the installation step finishes, you should see a new directory created: `/home/ec2-user/SageMaker/initsmnb/`.
Your next step is to jump to section [Usage](#14-usage).

## 1.4. Usage

Once installed, you should see file `/home/ec2-user/SageMaker/initsmnb/setup-my-sagemaker.sh`.

To apply the customizations to the current session, open a terminal and run
`~/SageMaker/initsmnb/setup-my-sagemaker.sh`. Once the script finishes, please
follow the on-screen instruction to restart the Jupyter server (and after that,
do remember to reload your browser tab).

Due to how SageMaker notebook works, please re-run `setup-my-sagemaker.sh` on a
newly *started* or *restarted* instance. You may even consider to automate this
step using SageMaker lifecycle config.

## 1.5. Appendix

### 1.5.1. Restart JupyterLab

On the Jupyter Lab's terminal, run this command:

```bash
sudo initctl restart jupyter-server --no-wait
```

After issuing the command, your Jupyter interface will probably freeze, which
is expected.

Then, reload your browser tab, and enjoy the new experience.

### 1.5.2. Change terminal font size

To change the terminal font size, after installation

1. open `/home/ec2-user/SageMaker/initsmnb/change-fontsize.sh` in a text editor,
2. go to the section that customizes the terminal,
3. then change the fontsize (default is 10) to another value of your choice.

## 1.6. Related Projects

Once you've customized your development environment on your SageMaker classic
notebook instance, we invite you to explore related samples.

1. [aws-samples/python-data-science-template](https://github.com/aws-samples/python-data-science-template/)
   shows a one-liner command line that instantenously auto-generate a modular
   structure for your new Python-based data science project.

2. [aws-samples/amazon-sagemaker-entrypoint-utilities](https://github.com/aws-samples/amazon-sagemaker-entrypoint-utilities)
   is a sample library to help you quickly write a SageMaker **meta**-entrypoint
   script for training. This approach aims to reduce the amount of boilerplate
   codes you need to write for model training, such as argument parsings and
   logger configurations, which are repetitive and tedious.

3. [ML Max](https://github.com/awslabs/mlmax/) is a set of example templates to
   accelerate the delivery of custom ML solutions to production so you can get
   started quickly without having to make too many design choices. At present,
   it covers four pillars: training pipeline, inference pipeline, development
   environment, and data management/ETL.

4. Learn about a different mechanism to create custom Jupyter kernel on a SageMaker
   classic notebook instance, described in
   [aws-samples/aws-sagemaker-custom-jupyter-kernel](https://github.com/aws-samples/aws-sagemaker-custom-jupyter-kernel/).

5. *Wearing an "infrastructure engineer" hat* -- when you're ready or allowed to
   implement the customizations as a lifecycle configuration for your SageMaker
   notebook instance, feel free to further explore these
   [examples](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/).

6. [Data science on Amazon EC2 with vim, tmux and zsh](https://github.com/aws-samples/ec2-data-science-vim-tmux-zsh/)
   hosts a simple template to set up basic Vim, Tmux, Zsh for the Deep Learning
   AMI Amazon Linux 2 for data scientists.

## 1.7. Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## 1.8. License

This library is licensed under the MIT-0 License. See the LICENSE file.
