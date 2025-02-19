# ----------------------------------------------------------------------------------------------------------------------
# IAM Role
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "iam_role" {
  name                = var.name
  assume_role_policy  = data.aws_iam_policy_document.assume.json

  tags = {
    Name = var.name
  }
}

resource "aws_iam_role_policy" "role_policy" {
  count = length(var.policies)

  name   = "${var.policies[count.index]}-policy"
  role   = aws_iam_role.iam_role.id
  policy = data.aws_iam_policy_document.policies[var.policies[count.index]].json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count = length(var.managed_policy_arns)

  role = aws_iam_role.iam_role.id
  policy_arn = var.managed_policy_arns[count.index]
}