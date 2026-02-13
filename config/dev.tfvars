region          = "us-east-1"
cluster_name    = "dev-eks-cluster"
cluster_version = "1.29"

vpc_id = "vpc-0a151bca5a0a22454"

private_subnet_ids = [
  "subnet-03ec53e5dd740527c",
  "subnet-09d4b21f3624e75f8"
]

cluster_role_arn = "arn:aws:iam::140191459435:role/eks-cluster-role"
node_role_arn    = "arn:aws:iam::140191459435:role/eks-node-role"

instance_types = ["t3.micro"]

desired_size = 1
min_size     = 1
max_size     = 2
