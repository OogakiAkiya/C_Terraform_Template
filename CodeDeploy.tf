
data "aws_iam_policy_document" "code_deploy"{
    statement{
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals{
            identifiers=["codedeploy.amazonaws.com"]
            type = "Service"
        }
    }
}

resource "aws_iam_role" "code_deploy"{
    name = "CodeDeployRole2"
    assume_role_policy = data.aws_iam_policy_document.code_deploy.json
}

//AWS管理ポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "code_deploy_policy"{
    role = aws_iam_role.code_deploy.name
    policy_arn= "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}


resource "aws_codedeploy_app" "app"{
    name             = "C_Test"
    compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "group"{
    app_name               = aws_codedeploy_app.app.name
    deployment_group_name  = "Servers"
    service_role_arn       = aws_iam_role.code_deploy.arn
    deployment_config_name = "CodeDeployDefault.AllAtOnce"
    ec2_tag_set {
        ec2_tag_filter {
            key   = "Name"
            type  = "KEY_AND_VALUE"
            value = aws_instance.jp.tags.Name
        }
    }
}
