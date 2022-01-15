########################
# Realiti Proxy Instance
########################

resource "aws_instance" "Dale_SaaS_Realiti_Proxy_Server" {
  ami               = "ami-0c6ebbd55ab05f070"
  instance_type     = "t3.micro"
  availability_zone = "eu-west-3c"
  key_name          = "(ssh key name)"
  vpc_security_group_ids      = [data.aws_security_group.Realiti_Security_Group.id]
  user_data = <<-EOL
  #!/bin/bash -xe

  apt update
  EOL

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
  }

  tags = {
    Name = "Dale_SaaS_Realiti_Proxy_Server"
  }
}

##################
# Realiti Instance
##################

resource "aws_instance" "Dale_SaaS_Realiti_Server" {
  ami               = "ami-018c55e9d34f949e9"
  instance_type     = "t3.2xlarge"
  availability_zone = "eu-west-3c"
  key_name          = "(ssh key name)"
  vpc_security_group_ids      = [data.aws_security_group.Realiti_Security_Group.id]
  user_data = <<-EOL
  #!/bin/bash -xe

  yum update -y
  EOL




   ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 75
  }

  tags = {
  Name = "Dale_SaaS_Realiti_Server"
  }
}

##################
# Tableau Instance
##################

resource "aws_instance" "Dale_SaaS_Tableau_Server" {
  ami               = "ami-018c55e9d34f949e9"
  instance_type     = "t3.2xlarge"
  availability_zone = "eu-west-3c"
  key_name          = "(ssh key name)"
  vpc_security_group_ids      = [data.aws_security_group.Realiti_Security_Group.id]
  user_data = <<-EOL
  #!/bin/bash -xe

  yum update -y
  dd if=/dev/zero of=/swapfile count=8192 bs=1MiB
  mkswap /swapfile
  chmod 600 /swapfile
  swapon /swapfile
  EOL




  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 75
  }

  tags = {
    Name = "Dale_SaaS_Tableau_Server"
  }
}

###################
# Database Instance
###################

resource "aws_instance" "Dale_SaaS_Database_Server" {
  ami               = "ami-018c55e9d34f949e9"
  instance_type     = "t3.2xlarge"
  availability_zone = "eu-west-3c"
  key_name          = "(ssh key name)"
  vpc_security_group_ids      = [data.aws_security_group.Realiti_Security_Group.id]
  user_data = <<-EOL
  #!/bin/bash -xe

  yum update -y
  EOL

   ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }

  tags = {
  Name = "Dale_SaaS_Database_Server"
  }
}

################
# Exsisting VPC
################


data "aws_vpc" "Default_VPC" {
  id = "(vpc-id)"
}

##################
# Exsisting Subnet
##################

data "aws_subnet" "Default_Subnet" {
  id = "(subnet-id)"
}

######################
# Elastic IP Addresses
######################

resource "aws_eip_association" "Realiti_Elastic_IP_Association" {
  instance_id   = aws_instance.Dale_SaaS_Realiti_Server.id
  allocation_id = aws_eip.Realiti_Elastic_IP.id
}

resource "aws_eip" "Realiti_Elastic_IP" {
  vpc = true
}


resource "aws_eip_association" "Realiti_Proxy_Elastic_IP_Association" {
  instance_id   = aws_instance.Dale_SaaS_Realiti_Proxy_Server.id
  allocation_id = aws_eip.Realiti_Proxy_Elastic_IP.id
}

resource "aws_eip" "Realiti_Proxy_Elastic_IP" {
  vpc = true
}


resource "aws_eip_association" "Tableau_Server_Elastic_IP_Association" {
  instance_id   = aws_instance.Dale_SaaS_Tableau_Server.id
  allocation_id = aws_eip.Tableau_Server_Elastic_IP.id
}

resource "aws_eip" "Tableau_Server_Elastic_IP" {
  vpc = true
}

resource "aws_eip_association" "Database_Server_Elastic_IP_Association" {
  instance_id   = aws_instance.Dale_SaaS_Database_Server.id
  allocation_id = aws_eip.Database_Server_Elastic_IP.id
}

resource "aws_eip" "Database_Server_Elastic_IP" {
  vpc = true
}

################
# Security Group
################

data "aws_security_group" "Realiti_Security_Group" {
  id =  "(sg-id)" 
  vpc_id = data.aws_vpc.Default_VPC.id
}

############
# EBS Volume
############

resource "aws_ebs_volume" "Dale_Saas_Tableau_Volume" {
  availability_zone = "eu-west-3c"
  size              = 50
}

#######################
# EBS Volume Attachment
#######################

resource "aws_volume_attachment" "EBS_Tableau_Attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.Dale_Saas_Tableau_Volume.id
  instance_id = aws_instance.Dale_SaaS_Tableau_Server.id

  depends_on = [ aws_instance.Dale_SaaS_Realiti_Server ]
}


################################
#  Tableau Disk Partition Script
################################


resource "null_resource" "copy_part_script" {
  
  connection {
  type = "ssh"
  host = aws_eip_association.Tableau_Server_Elastic_IP_Association.public_ip
  user = "ec2-user"
  private_key = file("(Path to ssh key)")
  
  }      


  provisioner "file" {
    source      = "part_script.sh"
    destination = "/tmp/part_script.sh"

  }


  provisioner "remote-exec" {
    inline = [
      "sudo chmod 770 /tmp/part_script.sh",
      "sudo sh /tmp/part_script.sh",
     ]
   }  
 
 depends_on = [ aws_instance.Dale_SaaS_Realiti_Server,
                aws_eip_association.Tableau_Server_Elastic_IP_Association, 
                aws_volume_attachment.EBS_Tableau_Attachment ]
  }

#############################
# Tableau Disk Mouting Script
#############################

resource "null_resource" "copy_mount_script" {
  
  connection {
  type = "ssh"
  host = aws_eip_association.Tableau_Server_Elastic_IP_Association.public_ip
  user = "ec2-user"
  private_key = file("(Path to ssh key)")
  
  }      


  provisioner "file" {
    source      = "mount_script.sh"
    destination = "/tmp/mount_script.sh"

  }


  provisioner "remote-exec" {
    inline = [
      "sudo chmod 770 /tmp/mount_script.sh",
      "sudo sh /tmp/mount_script.sh",
     ]
   }  
 
 depends_on = [ aws_instance.Dale_SaaS_Realiti_Server,
                aws_eip_association.Tableau_Server_Elastic_IP_Association, 
                aws_volume_attachment.EBS_Tableau_Attachment,
                null_resource.copy_mount_script 
                ]
 
 }