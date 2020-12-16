import boto3
client = boto3.client('elbv2')
response = client.describe_target_groups(
    LoadBalancerArn='arn:aws:elasticloadbalancing:eu-west-1:329794110703:loadbalancer/app/TestLb/a003431844c3a857')
print(response['TargetGroups'][0]['TargetGroupName'])
