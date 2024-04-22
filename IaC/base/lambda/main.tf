resource "aws_lambda_function" "backend" {
    function_name = "${var.environment}-${var.stack_name}-backend"
    role          = aws_iam_role.backend_lambda_role.arn
    filename      = "../../backend.zip"
    handler       = "main.handler"
    runtime       = "nodejs18.x"
    memory_size   = 512
    timeout       = 10
    environment {
        variables = {
            DYNAMODB_TABLE = var.dynamodb_table_name,
            S3_BUCKET_NAME = var.s3_bucket_name,
            S3_BUCKET_URL  = var.s3_bucket_url,
        }
    }
}

resource "aws_iam_role" "backend_lambda_role" {
    name = "${var.environment}-${var.stack_name}-backend-lambda-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
        }]
    })
}

resource "aws_iam_role_policy_attachment" "backend_lambda_dynamodb" {
    role       = aws_iam_role.backend_lambda_role.name
    policy_arn = var.dynamodb_policy_arn
}
resource "aws_iam_role_policy_attachment" "backend_lambda_s3" {
    role       = aws_iam_role.backend_lambda_role.name
    policy_arn = var.s3_policy_arn
}


data "aws_caller_identity" "current" {}
resource "aws_lambda_permission" "backend_lambda_permission" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    principal     = "apigateway.amazonaws.com"
    function_name = aws_lambda_function.backend.function_name
    source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*"
}

output lambda_invoke_arn {
    value = aws_lambda_function.backend.invoke_arn
}
