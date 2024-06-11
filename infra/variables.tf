variable "region" {
  type        = string
  description = "The AWS region used to run the resources"
  default     = "eu-west-1"
}

variable "project_name" {
  type        = string
  description = "The name of th project"
  default     = "serverless-app"
}
