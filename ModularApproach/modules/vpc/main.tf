resource "aws_vpc" "default" {
  cidr_block = "${var.cidr}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}
