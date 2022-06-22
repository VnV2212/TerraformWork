variable "AWS_ACCESS_KEY" {
  
}

variable "AWS_SECRET_KEY" {
  
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
