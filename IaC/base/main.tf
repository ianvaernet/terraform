provider "aws" {
    region      = var.aws_region
    # access_key  = "XXXXXXXXXXXXXXXXX"
    # secret_key  = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    # shared_credentials_files = ["/users/tf_user/.aws/credentials"]
}

module "s3_uploads" {
    source          = "./s3"
    stack_name      = var.stack_name
    environment     = var.environment
    bucket_name     = "${var.environment}-${var.stack_name}-uploads"
    is_website      = false
    template_files  = {}
}

module "s3_front" {
    source          = "./s3"
    stack_name      = var.stack_name
    environment     = var.environment
    bucket_name     = "${var.environment}-${var.stack_name}-front"
    is_website      = true
    template_files  = module.template_files.files
}

module "template_files" {
    source = "hashicorp/dir/template"
    base_dir = "../../frontend/${var.frontend_dist_folder_name}/browser"
}

module "dynamo" {
    source      = "./dynamo"
    stack_name  = var.stack_name
    environment = var.environment
}

module "lambda" {
    source              = "./lambda"
    aws_region          = var.aws_region
    stack_name          = var.stack_name
    environment         = var.environment
    dynamodb_policy_arn = module.dynamo.dynamodb_policy_arn
    dynamodb_table_name = module.dynamo.dynamodb_table_name
    s3_policy_arn       = module.s3_uploads.bucket_policy_arn
    s3_bucket_name      = module.s3_uploads.bucket_name
    s3_bucket_url       = module.s3_uploads.bucket_url
    api_gateway_id      = module.api_gateway.api_gateway_id
}

module "api_gateway" {
    source              = "./api_gateway"
    stack_name          = var.stack_name
    environment         = var.environment
    lambda_invoke_arn   = module.lambda.lambda_invoke_arn
}

output "api_invoke_url" {
    value = module.api_gateway.api_invoke_url
}
output "web_url" {
    value = module.s3_front.website_url
}
