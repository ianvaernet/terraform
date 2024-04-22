resource "aws_dynamodb_table" "dynamo_table" {
    name            = "${var.environment}-${var.stack_name}-db"
    billing_mode    = "PROVISIONED"
    read_capacity   = 5
    write_capacity  = 5
    hash_key        = "id"
    attribute {
        name = "id"
        type = "S"
    }
}

resource "aws_iam_policy" "dynamodb_crud_policy" {
  name        = "${var.environment}-${var.stack_name}-dynamodb-crud-policy"
  path        = "/"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        "Resource": "${aws_dynamodb_table.dynamo_table.arn}*",
        "Effect": "Allow"
    }]
  })
}

output "dynamodb_policy_arn" {
    value = aws_iam_policy.dynamodb_crud_policy.arn
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.dynamo_table.name
}
