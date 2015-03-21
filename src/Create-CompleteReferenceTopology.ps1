﻿param(
    $prefix = "https://s3-ap-southeast-2.amazonaws.com/bc-public-releases/AWS-Lego/Alpha/",
    $natkp = (Read-Host 'Name of Key Pair to user for NAT server instance access'),
    $natAmi = (Read-Host 'AMI ID of NAT'),
    $tags = @(
        @{"Key" = "Project"; "Value" = "Infrastructure"},
        @{"Key" = "Environment"; "Value" = "Prod"}
    )
)

.".\Deployment.ps1"

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/vpc.template" |
    Upsert-StackLink -Tags $tags -StackName Prod-PrimaryVpc |
    Wait-StackLink

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/internet-access.subnets.template" |
    Upsert-StackLink -Tags $tags -StackName Prod-GatewaySubnets |
    Wait-StackLink

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/webserver.subnets.template" |
    Upsert-StackLink -Tags $tags -StackName Prod-WebServerSubnets |
    Wait-StackLink

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/private.subnets.template" |
    Upsert-StackLink -Tags $tags -StackName Prod-PrivateSubnets |
    Wait-StackLink

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/nat-enabled.subnets.template" -StackParameters @(
    @{"Key" = "KeyPairName"; "Value" = $natkp},
    @{"Key" = "NatImageId"; "Value" = $natAmi}
) | Upsert-StackLink -Tags $tags -StackName Prod-NatSubnets |
    Wait-StackLink

Get-StackLinkParameters -TemplateUrl "$($prefix)basic-blocks/elb.subnets.template" |
    Upsert-StackLink -Tags $tags -StackName Prod-ElbSubnets |
    Wait-StackLink