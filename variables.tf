variable "role_arn" {
  type = string
  description = "Aws asumerole role"
  default = "617813585939"
  # ⬆️⬆️⬆️ management id ⬆️⬆️⬆️
}

variable "aws_region" {
  type = string
  description = "Aws region"
  default = "eu-central-1"
}
