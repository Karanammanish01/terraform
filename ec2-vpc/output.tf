# output "public_vm_ip_address" {
#   value = aws_instance.ec2_vm.public_ip
# }

output "public_vm_ip_address" {
  value = aws_instance.ec2_vm[*].public_ip
}

# this is output for {for_each}
output "backend_vm_proivate_ip" {
  value = [
    for instance in aws_instance.private-vm : instance.private_ip
  ]
}