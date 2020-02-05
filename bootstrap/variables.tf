variable "ami" {
  type = string
}

variable "type" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "subnet_id" {
  type = string
}