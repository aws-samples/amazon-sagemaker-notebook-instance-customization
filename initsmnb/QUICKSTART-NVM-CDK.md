# Quickstart to CDK on Amazon SageMaker notebook instance

This quickstart assumes that you've installed and ran
[initsmnb](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization) to set a
few environment variables in your `~/.bashrc`. Please refer to your `~/.bashrc` or
`~/SageMaker/initsmnb/cdk-pre-requisites.sh` for the affected of the environment variables.

## Install node.js on Amazon SageMaker notebook instance

Open a terminal, and run the next stanza to install nvm, node.js, and CDK that survive reboot.

```bash
################################################################################
# Run this stanza only 1x on a new notebook instance.
#
# Please change the software versions accordingly. Also, please note that CDK
# mandates specific recommended versions of node.js.
################################################################################

# Eyeball that NVM_DIR points to ~/SageMaker/*
echo "NVM_DIR=$NVM_DIR"

# Install nvm to NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash

# Activate for the current terminal session. Otherwise, simply open a new terminal to start
# working with the just-installed nvm.
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # Loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"  # Loads nvm bash_completion
echo "Checking nvm:" `command -v nvm`

# Install node.js
#nvm install node
nvm install 16.3.0
nvm use 16.3.0
node -e "console.log('Running Node.js ' + process.version)"
echo "Checking npm:" `npm -v`

# Install cdk
npm install -g aws-cdk

# Run once, and see if there's any warning re. incompatible node.js version
cdk
```

## Optional: Prepare helper environment variables

Run this stanza when you want to override the defaults set by
[initsmnb](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization) in your
`~/.bashrc`.

```bash
export CDK_DEFAULT_ACCOUNT=111122223333
export CDK_DEFAULT_REGION=ap-southeast-1
```

## Bootstrap CDK to AWS account

**Requirements**: make sure the instance where you run the cdk client has the necessary permissions
to create an S3 bucket and deploy CloudFormation stacks.

For more details, see <https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html#getting_started_bootstrap>

```bash
# Cdk client will create an S3 bucket on account ID xxxxyyyyzzzz.
cdk bootstrap aws://${CDK_DEFAULT_ACCOUNT}/${CDK_DEFAULT_REGION}
```

## Create a CDK app

```bash
mkdir -p ROOT_OF_MY_CDK_APP
cd ROOT_OF_MY_CDK_APP
cdk init app --language python
```

From here, we have deviate from the CDK-generated `README.md`: instead of virtualenv, we just use a
Conda environment.

```bash
conda create --prefix ~/SageMaker/envs/cdk-conda-env python=3.9 ipykernel
conda activate ~/SageMaker/envs/cdk-conda-env

pip install -r requirements.txt
pip install -r requirements-dev.txt
```

## Deploy Stack

First time deployment:

```bash
cdk synth
cdk deploy
```

Your CDK template may need to create a few IAM roles, so make sure that the AWS credential (e.g.,
a SageMaker execution role) that deploys the stack has the necessary permissions to CRUD IAM
permissions and/or roles.

Below is just an example of what the AWS credential may need:

```text
{
    "Sid": "VisualEditor0",
    "Effect": "Allow",
    "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",  # For creating, e.g., lambda's execution roles
        "iam:DeleteRolePolicy", # For deleting, e.g., lambda's execution roles
        "kms:ListAliases", # To resolve key alias for SNS topic.
    ],
    "Resource": "*"    # NOTE: you may want to further restrict the resources here.
}
```

After modifications:

```bash
# See the differences
cdk diff

# Update the existing stack
cdk deploy
```

## Stand-down Stack

```bash
cdk destroy
```

## Appendix: Install CDK on plain Amazon SageMaker notebook instance.

This section is provided as a courtesy for those who're not using
[initsmnb](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization). Please
note that this section may be outdated compared to the GitHub repository.

```bash
################################################################################
# STEP-0: install CDK -- do this only 1x on a new notebook instance.
#
# Please change the software versions accordingly. Also, please note that CDK
# mandates specific recommended versions of node.js.
################################################################################
# Install nvm to NVM_DIR
mkdir -p ~/SageMaker/.initsmnb.d/.nvm/
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | NVM_DIR=~/SageMaker/.initsmnb.d/.nvm bash

# Activate for a terminal session. Alternatively, on every reboot, add this stanza to ~/.bashrc.
#
# [NOTE] although nvm install will add the next stanza to ~/.bashrc, this file will be factory-reset
# on reboot, causing this stanza to disappear. Hence, you'll need to run this stanza on every
# terminal you open, or re-add to ~/bashrc.
export NVM_DIR="$HOME/SageMaker/.initsmnb.d/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # Loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"  # Loads nvm bash_completion
echo "Checking nvm:" `command -v nvm`

# Install node.js.
#nvm install node
nvm install 16.3.0
nvm use 16.3.0
node -e "console.log('Running Node.js ' + process.version)"
echo "Checking npm:" `npm -v`

# Install cdk
npm install -g aws-cdk

# Run once, and see if there's any warning re. incompatible node.js version
cdk


################################################################################
# STEP-1: Programmatically default the CDK_DEFAULT_* environment variables to
#         the region of your notebook instance.
################################################################################
# To bootstrap CDK to the account ID associated with the current credential.
# You may want to change to specific account ID instead.
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | sed -e 's/"//g' -e 's/,//g')

# To deploy a CDK stack to the region where the current EC2 or notebook instance is running.
# You may want to change to specific region instead.
export EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
export CDK_DEFAULT_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
```