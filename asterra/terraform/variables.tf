variable "aws_region" {
  default = "us-east-2"
}

variable "project_name" {
  default = "astera-devops"
}

variable "db_username" {
  default = "asterauser"
}

variable "db_password" {
  default     = "StrongPassword123!"
  sensitive   = true
  description = "Password must meet RDS requirements."
}

variable "db_engine_version" {
  default     = "15.4"
  description = "Aurora PostgreSQL engine version"
}

variable "db_instance_class" {
  default     = "db.serverless"
  description = "Instance class for Aurora PostgreSQL"
}

variable "db_instance_count" {
  default     = 1
  description = "Number of RDS cluster instances"
}

variable "allowed_rdp_ip" {
  description = "CIDR block allowed to access RDP"
  default     = "0.0.0.0/24"
}

variable "iac_storage_bucket" {
  default = "astera-iac-storage"
}
