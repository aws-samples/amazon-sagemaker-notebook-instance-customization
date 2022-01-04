# Quickstart to CDK on Amazon SageMaker notebook instance

This quickstart assumes that you've used
[initsmnb](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-customization) to
install a persistent copy of CDK, nvm, and Node.js on your Amazon SageMaker notebook instance.

Please note that the install script avoids reinstalling any of those software should it already
exists under `$NVM_DIR` is detected. As such, in practice the actual installs happen you run
`initsmnb` the first time on your fresh, brand new notebook instance.

A few environment variables will be added to your `~/.bashrc`:

- `$NVM_DIR` set to `/home/ec2-user/SageMaker/.initsmnb.d/.nvm` which is the directory that contains
  the installed cdk, nvm, and node.js. Because `$NVM_DIR` is under `~/SageMaker`, its contents
  survive reboot.
- `$CDK_DEFAULT_ACCOUNT` set to your AWS account ID
- `$CDK_DEFAULT_REGION` set to the region of your SageMaker notebook instance
- `$EC2_AVAIL_ZONE` set to the availability zone of your SageMaker notebook instance

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
