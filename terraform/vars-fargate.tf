variable "Container_Port" {
  type = number
  default = 80
}

variable "Host_Port" {
  type = number
  default = 80
}

variable "ECR_Image" {
  type = string
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