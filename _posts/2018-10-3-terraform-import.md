---
layout: post
title: Tutorial of using terraform import for syncing terraform state
image: /assets/img/terraform-import/cover.png
readtime: 20 minutes
---

*It's worth noting that its always much simpler to create the terraform first, you would only ever import when you need to do something reactive, like an emergency release*

There are two reasons you would want to do this.

You created a resource in the aws management console, and you now want to track the resource via terraform 

    1 - And you already defined the definition in terraform
    
    2 - And you need to create a definition based on existing resource


At present time, it's not possible to directly take an AWS resource, and import into a terraform file, but you can get the state equivalent and convert that into a definition.

It's also worth noting that each import has a different syntax, so its worth checking with the AWS documentation, but here are some examples to get you going.


### 1 - You have already defined the resource and want to tell the state that this resource already exists.

Take the scenario:

Something was going wrong in live, and you quickly had to make a change to a change to add a DNS record to route 53. Once things had settled down you defined the same record in your terraform file, but when you ran apply, you found that the resource already existed, causing the apply to fail.

You want to import the state that already exists, so that next time you apply, terraform already knows that the resource exists, and any changes made going forward will be picked up as modifications.


I'm going to pretend that in an emergency, I created the following

`Route53 Record Set Name: www.mywebsite.com.`

`Route53 Record Set Type: CNAME`

`Route53 Record Set Value: mywebsite.com.`

When things settled down, I created the following terraform, hoping it would match:

```
resource "aws_route53_record" "www" {
  name = "www.mywebsite.com"
  type = "CNAME"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["mywebsite.com"]
  ttl = 300
}

data "aws_route53_zone" "zone" {
  name         = "mywebsite.com"
  private_zone = false
}
```

When I apply, I get something like:

```
* aws_route53_record.www: 1 error(s) occurred:

* aws_route53_record.www: [ERR]: Error building changeset: InvalidChangeBatch: RRSet of type CNAME with DNS name www.mywebsite.com. is not permitted as it conflicts with other records with the same DNS name in zone mywebsite.com.
	status code: 400

```

To sync the state, I do the following:

```
AWS_PROFILE=mywebsite terraform import aws_route53_record.www Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME


Which corresponds to:
AWS_PROFILE={AwsProfileName} terraform import {resource_type}.{resource_name} {zone_id}_{record_name}_{record_type}
```

[terraform documentation](https://www.terraform.io/docs/providers/aws/r/route53_record.html)

Which should then update the state, and return something like:

```
aws_route53_record.www: Importing from ID "Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME"...
aws_route53_record.www: Import complete!
  Imported aws_route53_record (ID: Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME)
aws_route53_record.www: Refreshing state... (ID: Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME)

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

If I get an error like the below:

```
aws_route53_record.www: Importing from ID "Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME"...
aws_route53_record.www: Import complete!
  Imported aws_route53_record (ID: Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME)

Error: aws_route53_record.www (import id: Z0ZZZZZZ0ZZZZ0_www.mywebsite.com_CNAME): Can't import aws_route53_record.www, would collide with an existing resource.

Please remove or rename this resource before continuing.
```

Its because the resource already exists in the terraform state.



## 2 - You have not defined the resource need to build a resource from an existing state.

This usually where you have something like an EC2 instance, but not sure of the settings etc. and would find it hard to build the resource without getting the settings that it was originally deployed with.

Take the scenario:

Something went wrong, and you had to quickly migrate from a physical server to EC2. You spun up an EC2 and applied a load of settings. Once things settled down, you wanted to build the terraform and sync the state

You don't know where to start, all you know is that we built an EC2 instance


I'm going to pretend that in an emergency I created the following

`EC2 instance Name: mywebsite-server`

In order to import, I need a resource, with a matching type to be able to do the import, something like:

```
resource "aws_instance" "mywebsite-server" {
}
```

Then run the import using the terraform documentation 

```
AWS_PROFILE=mywebsite terraform import aws_instance.mywebsite-server i-0Z000ZZ0Z0Z00Z0Z0


Which corresponds to:
AWS_PROFILE={AwsProfileName} terraform import {resource_type}.{resource_name} {instance_id}
```

Which should, if working return something like

```
aws_instance.mywebsite-server: Importing from ID "i-0Z000ZZ0Z0Z00Z0Z0"...
aws_instance.mywebsite-server: Import complete!
  Imported aws_instance (ID: i-0Z000ZZ0Z0Z00Z0Z0)
aws_instance.mywebsite-server: Refreshing state... (ID: i-0Z000ZZ0Z0Z00Z0Z0)

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

```

If you look at the state file, you should be able to get the description of the instance, e.g.

```
"resources": {
                "aws_instance.mywebsite-server": {
                    "type": "aws_instance",
                    "depends_on": [],
                    "primary": {
                        "id": "i-0Z000ZZ0Z0Z00Z0Z0",
                        "attributes": {
                            "ami": "ami-zzz00zz0",
                            "arn": "arn:aws:ec2:eu-west-2:XXXXXXXXXXXX:instance/i-0Z000ZZ0Z0Z00Z0Z0",
                            "associate_public_ip_address": "true",
                            "availability_zone": "eu-west-2a",
                            "cpu_core_count": "1",
                            "cpu_threads_per_core": "1",
                            "credit_specification.#": "1",
                            "credit_specification.0.cpu_credits": "standard",
                            "disable_api_termination": "false",
                            "ebs_block_device.#": "0",
                            "ebs_optimized": "false",
                            "ephemeral_block_device.#": "0",
                            "get_password_data": "false",
                            "iam_instance_profile": "",
                            "id": "i-0Z000ZZ0Z0Z00Z0Z0",
                            "instance_state": "running",
                            "instance_type": "t2.micro",
                            "ipv6_addresses.#": "0",
                            "key_name": "mywebsite",
                            "monitoring": "false",
                            "network_interface.#": "0",
                            "network_interface_id": "eni-00zzzzz00zz000z00",
                            "password_data": "",
                            "placement_group": "",
                            "primary_network_interface_id": "eni-00zzzzz00zz000z00",
                            "private_dns": "ip-1-1-1-1.eu-west-2.compute.internal",
                            "private_ip": "1.1.1.1",
                            "public_dns": "ec2-1-1-1-1.eu-west-2.compute.amazonaws.com",
                            "public_ip": "1.1.1.1",
                            "root_block_device.#": "1",
                            "root_block_device.0.delete_on_termination": "true",
                            "root_block_device.0.iops": "0",
                            "root_block_device.0.volume_id": "vol-0z00zz0zzz000z0zz",
                            "root_block_device.0.volume_size": "8",
                            "root_block_device.0.volume_type": "standard",
                            "security_groups.#": "0",
                            "source_dest_check": "true",
                            "subnet_id": "subnet-000000z0000z00z0z",
                            "tags.%": "1",
                            "tags.Name": "MyWebsite",
                            "tenancy": "default",
                            "user_data": "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
                            "volume_tags.%": "0",
                            "vpc_security_group_ids.#": "1",
                            "vpc_security_group_ids.3064782471": "sg-00zz00zzz00zz0000"
                        },
                        "meta": {
                            "e2bfb730-ecaa-11e6-8f88-34363bc7c4c0": {
                                "create": 600000000000,
                                "delete": 1200000000000,
                                "update": 600000000000
                            },
                            "schema_version": "1"
                        },
                        "tainted": false
                    },
                    "deposed": [],
                    "provider": "provider.aws"
                }
            },
```

From here, it's possible to build the resource based on the settings in the state.

Be wary though, you can't set some properties, as they are autogenerated, so its worth running a plan to see if your import looks right after converting into the terraform resource
