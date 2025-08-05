variable "Env" {
  type = string
}


variable "Environment" {
  default = {
    dev = "Development"
    prod = "Production"
  }
}


variable "port" {
  default = {
    dev = 8080
    prod = 8080
  }
}

variable "ecs_cpu_usage" {
  default = {
    dev = 10
    prod = 100
  }
}

variable "ecs_task_count" {
  default = {
    dev = 1
    prod = 2
  }
}

variable "ecs_memory_usage" {
  default = {
    dev = 256
    prod = 512
  }
}


variable "log_group_prefix" {
  default = "mathias-applogs"
}

locals {
    required_tags = {
      Creator     = "mathias"
      Project     = "iac-task"
      Environment = var.Environment[var.Env]
  }
}
