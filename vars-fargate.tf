variable "Container_Port" {
  type = number
  default = 8080
}

variable "Host_Port" {
  type = number
  default = 8080
}

variable "ECR_Image" {
  type = string
  default = "329794110703.dkr.ecr.eu-west-1.amazonaws.com/dklocek:latest"
}

variable "Task_Role_Arn" {
  type = string
  default = "arn:aws:iam::329794110703:role/ecsTaskExecutionRole"
}

variable "Execution_Role_Arn" {
  type = string
  default = "arn:aws:iam::329794110703:role/ecsTaskExecutionRole"
}

variable "Definition_CPU" {
  type = number
  default = 256
}

variable "Definition_Memory" {
  type = number
  default = 512
}