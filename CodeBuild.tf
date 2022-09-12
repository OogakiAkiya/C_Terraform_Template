
//------------------------------------
//IAM関係
//------------------------------------

data "aws_iam_policy_document" "assume_role_policy"{
    statement{
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals{
            identifiers=["codebuild.amazonaws.com"]
            type = "Service"
        }
    }
}

resource "aws_iam_role" "code_build"{
    name = "codebuild-c-build-service-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "code_build_policy"{
    //CloudWatch権限
    statement{
        effect="Allow"
        resources = [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
        ]
        actions=[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
    }

    //s3への疎通解放(pipeline用のバケット)
    statement{
        effect = "Allow"
        resources=[
            "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.bucket}/*",
            "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket.bucket}"
        ]
        actions=[
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
        ]

    }
    //codecommitのpull権限
    statement{
        effect = "Allow"
        resources=[
            "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_codecommit_repository.C_Test.repository_name}"
        ]        
        actions = [
            "codecommit:GitPull"
        ]

    }
    
    //s3の疎通解放(codebuild用のバケット)
    statement{
        effect= "Allow"
        resources=[
            "arn:aws:s3:::${aws_codebuild_project.build.artifacts[0].location}",
            "arn:aws:s3:::${aws_codebuild_project.build.artifacts[0].location}/*",
        ]
        actions=[
            "s3:PutObject",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
        ]
    }
    
    //codebuild関連の権限
    statement{
        effect = "Allow"
        resources=[
            "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${aws_codebuild_project.build.name}"
        ]        
        actions=[
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
        ]
    }
}

//自作ポリシーのアタッチ
resource "aws_iam_role_policy" "code_build_policy"{
    role = aws_iam_role.code_build.name
    policy= data.aws_iam_policy_document.code_build_policy.json
}

//AWS管理ポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "deploy_policy"{
    role = aws_iam_role.code_build.name
    policy_arn= "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
}


//------------------------------------
//CodeBuild
//------------------------------------

resource "aws_codebuild_project" "build"{
    name = "c-build"
    service_role = aws_iam_role.code_build.arn
    artifacts{
        type = "S3"
        location="c-build-artifact"
    }
    environment{
        type = "LINUX_CONTAINER"
        compute_type= "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    }
    source{
        type = "CODECOMMIT"
        location = aws_codecommit_repository.C_Test.clone_url_http 
        git_clone_depth=1
    }

    //ソースバージョン
    //リファレンスタイプ:ブランチ(他にGitなど)
    //ブランチ:master
    source_version = "refs/heads/master"
}

