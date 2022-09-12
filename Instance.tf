//------------------------------------
//IAM関係
//------------------------------------
resource "aws_iam_role" "instance"{
    name = "WebRole"
    assume_role_policy = data.aws_iam_policy_document.instance.json
}

resource "aws_iam_instance_profile" "instance" {
  name = "WebRole"
  role = aws_iam_role.instance.name
}

data "aws_iam_policy_document" "instance"{
    statement{
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals{
            identifiers=["ec2.amazonaws.com"]
            type = "Service"
        }
    }
}

resource "aws_iam_role_policy_attachment" "instance_codecommit"{
    role = aws_iam_role.instance.name
    policy_arn= "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

resource "aws_iam_role_policy_attachment" "instance_SSM"{
    role = aws_iam_role.instance.name
    policy_arn= "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
resource "aws_iam_role_policy_attachment" "instance_S3"{
    role = aws_iam_role.instance.name
    policy_arn= "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "instance_Managed"{
    role = aws_iam_role.instance.name
    policy_arn= "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

//------------------------------------
//instance
//------------------------------------
resource "aws_instance" "jp" {
    ami="ami-01748a72bed07727c"
    instance_type = "t2.micro"
    subnet_id=aws_subnet.public.id
    vpc_security_group_ids=[aws_security_group.jp.id]
    iam_instance_profile =  aws_iam_instance_profile.instance.name
    tags={
        Name="terraform_test"
    }
}

/*
resource "aws_cloudwatch_metric_alarm" "cw"{
    alarm_name="temptemp"
    comparison_operator="GreaterThanOrEqualToThreshold"
    evaluation_periods=1   
    alarm_actions=["arn:aws:sns:ap-northeast-1:862806302714:Default_CloudWatch_Alarms_Topic"]
    datapoints_to_alarm=1
    metric_name                           = "StatusCheckFailed"
    namespace                             = "AWS/EC2"
    period                                = 60 
    statistic                             = "Maximum"
    threshold                             = 2
    treat_missing_data                    = "missing"
    dimensions={"InstanceId" = "i-02fe301f878a98251"}
}
*/