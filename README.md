# Terraform On Aws

Terraform On Aws

## IAM 계정 생성

`AmazonEC2FullAccess` 권한을 부여한 IAM 계정을 생성합니다.

정책에 `create_role` 정책을 아래의 내용으로 추가합니다.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1469200763880",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:TagRole",
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:DeleteRole",
                "iam:CreateInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:GetRolePolicy",
                "iam:DeleteRolePolicy"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```

`create_role` 권한을 부여합니다.

aws-cli 를 설정합니다.

```bash
aws configure
--------------------------------------
AWS Access Key ID [None]: AKIA3VXXXXXXXXXX
AWS Secret Access Key [None]: sDSWqBzAyunFXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: ap-northeast-2
```

## ssh key 생성

[참고](https://jhooq.com/terraform-ssh-into-aws-ec2/)

### key-pair 생성(ssh-keygen 이용)

파일명은 `/home/skyer9/.ssh/aws_key` 처럼 전체 경로를 적어 주어야 합니다.

비밀번호는 입력하지 않습니다.

```bash
ssh-keygen -t rsa -b 2048
--------------------------------------
Generating public/private rsa key pair.
Enter file in which to save the key (/home/skyer9/.ssh/id_rsa): /home/skyer9/.ssh/aws_key
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/skyer9/.ssh/aws_key
Your public key has been saved in /home/skyer9/.ssh/aws_key.pub
The key fingerprint is:
SHA256:dAjs1z4U2pZxskXXXXXXXXXXXXXXXXXXXXX skyer9@notebook
The key's randomart image is:
+---[RSA 2048]----+
|     ..     ..+*=|
|      ..+.* ..oB+|
|   XXXXXXXXXXXXXX|
|      ..=.X  .E.+|
|       .S= .  .oo|
|        XXXXXXXXX|
|     XXXXXXXXXXXX|
|   XXXXXXXXXXXXXX|
|             o   |
+----[SHA256]-----+

```

```bash
ls -al .ssh/aws_key*
--------------------------------------
-rw------- 1 skyer9 skyer9 1823  8월 28 20:34 .ssh/aws_key
-rw-r--r-- 1 skyer9 skyer9  397  8월 28 20:34 .ssh/aws_key.pub
```

## 보안 그룹 생성

```bash
cd security_group

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Consul Server Cluster 생성

```bash
cd ../consul_server_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Nomad Server Cluster 생성

```bash
cd ../nomad_server_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Nomad Client Cluster 생성

```bash
cd ../nomad_client_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```
