variable "primary" {
    type = list(string)
    default = ["name-1", "name-2", "name-3", "name-4"]
  
}
variable "secondary" {
    type = list(string)
    default =["name-1-dr", "name-2-dr", "name-3-dr", "name-4-dr"]
  
}
variable "aws_primary_alias" {
  type = string
  default = "primary"
}

variable "aws_secondary_alias" {
    type = string
    default = "secondary"
  
}
variable "force_destroy" {
  type    = string
  default = false
}
variable "tags" {
  type    = map(string)
  default = {
    program = "sysops"
    project = "terraform"
    Environment = "lower"

  }
}
