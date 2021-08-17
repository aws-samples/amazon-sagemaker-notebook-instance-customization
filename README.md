# Sample Scripts to Customize SageMaker Notebook Instance

Scripts to re-run common tweaks on a fresh (i.e., newly created or rebooted)
SageMaker notebook instance, to make the notebook instance a little bit more
ergonomic for prolonged usage.

Once [installed](#installation-from-github), everytime you access a newly
restarted notebook instance, open a terminal, run
`~/SageMaker/initsmnb/setup-my-sagemaker.sh`, then
[restart the Jupyter process](#appendix-restart-jupyterlab).

Please note that tweaks marked with **\[Need sudo\]** can only be in-effect when
your notebook instance enables
[root access for notebook users](https://aws.amazon.com/blogs/machine-learning/control-root-access-to-amazon-sagemaker-notebook-instances/).

- Jupyter Lab:
  * Reduce font size on Jupyter Lab
  * **\[Need sudo\]** Terminal defaults to `bash` shell, dark theme, and smaller font.
  * **\[Need sudo\]** Jupyter Lab to auto-scan `/home/ec2-user/SageMaker/envs/` for custom conda
    environments. Note that after you create a new custom conda environment on
    `/home/ec2-user/SageMaker/envs/`, you may need to
    [restart JupyterLab](#appendix-restart-jupyterlab) before you can see the
    environment listed as one of the kernels.

    This allows for a "persistent" conda environment that survives instance reboot.

- Git:
  * Optionally change committer's name and email, which defaults to `ec2-user`
  * git aliases: `git lol`, `git lola`, `git lolc`, and `git lolac`
  * New repo (i.e., `git init`) defaults to branch `main`
  * **\[Need sudo\]** `nbdime` for notebook-friendly diffs

- Terminal:
  * `bash` shortcuts: `alt-.`, `alt-b`, `alt-d`, and `alt-f` work even when
    connecting from OSX.
  * **\[Need sudo\]** Install command lines: `htop`, `tree`, `dos2unix`,
    `dstat`, `tig`, `ranger` (the CLI file explorer).
    + `ranger` is configured to use relative line numbers

- ipython run from Jupyter Lab's terminal:
  * shortcuts: `alt-.`, `alt-b`, `alt-d`, and `alt-f` work even when connecting
    from OSX.
  * recolor `o.__class__` from dark blue (nearly invisible on the dark theme) to
    a more sane color.

- Some customizations on `vim`:
  * Notably, change window navigation shortcuts from `ctrl-w-{h,j,k,l}` to
    `ctrl-{h,j,k,l}`.

    Otherwise, `ctrl-w` is used by most browsers on Linux (and Windows?) to
    close a browser tab, which renders windows navigation in `vim` unusable.

  * Other opinionated changes; see `init-vim.sh`.

- **\[Need sudo\]** Optionally mount one or more EFS.

## Installation from github

This step needs to be done **once** on a newly *created* notebook instance.

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

## Installation from local source

On your SageMaker notebook instance:

```bash
$ cd ~/SageMaker
$ git clone https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization.git
$ cd amazon-sagemaker-notebook-instance-customization/initsmnb
$ ./install-initsmnb-sh --from-local ...
```

## Usage

Once installed, you should see file `/home/ec2-user/SageMaker/initsmnb/setup-my-sagemaker.sh`.

Run this file to apply the changes to the current session, and follow the
instruction to restart the Jupyter server (and after that, do remember to reload
your browser tab).

Due to how SageMaker notebook works, please re-run `setup-my-sagemaker.sh` on a
newly *started* or *restarted* instance. You may even consider to automate this
step using SageMaker lifecycle config.

## Appendix: Restart JupyterLab

On the Jupyter Lab's terminal, run this command:

```bash
sudo initctl restart jupyter-server --no-wait
```

Then, reload your browser tab.

## Appendix: different terminal font size

To change the terminal font size, after installation

1. open `/home/ec2-user/SageMaker/initsmnb/change-fontsize.sh` in a text editor,
2. go to the section that customizes the terminal,
3. then change the fontsize (default is 10) to another value of your choice.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
