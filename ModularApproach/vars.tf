variable "AWS_ACCESS_KEY" {
  default="AKIA3VZ6MMPDXZ3NM57X"
}

variable "AWS_SECRET_KEY" {
  default="Ybk3Ovqsm+2dBlvhIhpvkMw/IJ/oAWRP1FKoc2TF"
}

variable "AWS_REGION" {
  default = "ap-south-1"
}

variable "AMIS" {
  type = map(string)
  default = {
    ap-south-1 = "ami-0f2e255ec956ade7f"
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = "8080"
}
