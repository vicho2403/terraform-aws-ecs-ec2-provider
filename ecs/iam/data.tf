data "aws_iam_policy_document" "assume" {
  source_policy_documents = [
    {
      "ecs-tasks" = data.aws_iam_policy_document.assume_ecs_tasks
      "ec2"       = data.aws_iam_policy_document.assume_ec2
    }[var.assume].json
  ]
}

data "aws_iam_policy_document" "assume_ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policies" {
  for_each = {
    multiple_enis = {
      actions   = ["ecs:PutAccountSetting"]
      effect    = "Allow"
      resources = ["*"]
    }
  }

  statement {
    actions = each.value.actions
    effect  = each.value.effect

    resources = each.value.resources
  }
}