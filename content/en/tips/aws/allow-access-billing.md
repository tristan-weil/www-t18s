---
title: "Allowing access to billing"
menuTitle: "Allowing access to billing"
description: "Allowing access to billing for authorized users"
---

In order to access the *Billing* panel in the AWS Consol, you need to configure a policy and a feature.

You will have to make the following procedure with your **root** account.

## The Policy

Attach the following policy to the group that will need to access the *Billing* panel.

Here it's the **admin** group:
![AWS IAM group ops](/images/tips/aws_iam_group_admin.png)

The policy:

{{< highlight json >}}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1559768044000",
      "Effect": "Allow",
      "Action": [
        "budgets:ViewBudget"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Stmt1559768057000",
      "Effect": "Allow",
      "Action": [
        "aws-portal:ViewAccount",
        "aws-portal:ViewBilling",
        "aws-portal:ViewPaymentMethods",
        "aws-portal:ViewUsage"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Stmt1559768080000",
      "Effect": "Allow",
      "Action": [
        "ce:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
{{< /highlight >}}

## Activate the access

In the navigation bar, choose your account name, and then choose **My Account**. \
Next to **IAM User and Role Access to Billing Information**, choose **Edit**. \
Then select the check box to **Activate IAM Access** and choose **Update**.

![AWS IAM group ops](/images/tips/aws_iam_billing.png)
