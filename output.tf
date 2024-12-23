output "vpc_name" {
    description = "this is my vpc id"
    value = aws_vpc.vpc_name.id
  
}
output "vpc-subnet1" {
    description = "this is my subnet 1 id"
    value = aws_subnet.vpc-subnet1.id
  
}
output "vpc-subnet2" {
    description = "this is my subnet 2 id"
    value = aws_subnet.vpc-subnet2.id
  
}
output "vpc-subnet3" {
    description = "this is my subnet 3 id"
    value = aws_subnet.vpc-subnet3.id
}
output "vpc-rt1" {
    description = "this is my 1st route table id"
    value = aws_route_table.vpc-rt1.id
}
output "vpc-rt2" {
    description = "this is my 2nd route table id"
    value = aws_route_table.vpc-rt2.id
}
output "vpc-rt3" {
    description = "this is my 3rd route table id"
    value = aws_route_table.vpc-rt3.id
}


