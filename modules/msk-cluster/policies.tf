###################################################
# Policy for MSK Cluster
###################################################

resource "aws_msk_cluster_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  cluster_arn = aws_msk_cluster.this.arn
  policy      = var.policy
}
