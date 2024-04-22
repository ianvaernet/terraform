variable "aws_region" {
    type        = string
    description = "AWS region where the stack will be deployed"
}
variable "stack_name" {
    type          = string
    description   = "Name to be used across all the stack"
}
variable "environment" {
    type          = string
    description   = "The environment to deploy"
    validation {
        condition       = contains(["dev", "qa", "stage", "prod"], var.environment)
        error_message   = "Allowed values for environment are \"dev\", \"qa\", \"stage\", or \"prod\"."
    }
}
variable "frontend_dist_folder_name" {
    type          = string
    description   = "Name of the folder with the build output"
}
