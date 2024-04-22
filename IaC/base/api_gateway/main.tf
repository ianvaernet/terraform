resource "aws_api_gateway_rest_api" "rest_api_gateway" {
    name                = "${var.environment}-${var.stack_name}-rest-api-gateway"
    binary_media_types  = ["*/*"]
}

resource "aws_api_gateway_resource" "resource" {
    parent_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method_any" {
    rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
    resource_id   = aws_api_gateway_resource.resource.id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
    type                      = "AWS_PROXY"
    integration_http_method   = "POST"
    http_method               = aws_api_gateway_method.method_any.http_method
    resource_id               = aws_api_gateway_resource.resource.id
    rest_api_id               = aws_api_gateway_rest_api.rest_api_gateway.id
    uri                       = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
    triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.resource,
            aws_api_gateway_method.method_any,
            aws_api_gateway_integration.integration,
        ]))
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "stage" {
    rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
    deployment_id = aws_api_gateway_deployment.deployment.id
    stage_name    = "api"
}

output "api_gateway_id" {
    value = aws_api_gateway_rest_api.rest_api_gateway.id
}
output "api_invoke_url" {
    value = aws_api_gateway_stage.stage.invoke_url
}
