---
layout: post
title: Terraform dependency graphing visualisations
image: /assets/img/terraform-graph/cover.png
readtime: 4 minutes
---

There a really cool feature of terraform that I only just found out about, Terraform Graph. Terraform Graph outputs a visual dependency graph of the resources that are inside it's configuration.

You can run it from the command line, as you would any other terraform command such as

```
terraform graph 
```

Which will output something like
```
C:\Users\craig.godden-payne\Desktop\terra>terraform graph
digraph {
        compound = "true"
        newrank = "true"
        subgraph "root" {
                "[root] aws_api_gateway_base_path_mapping.site_api" [label = "aws_api_gateway_base_path_mapping.site_api", shape = "box"]
                "[root] aws_api_gateway_deployment.site_api" [label = "aws_api_gateway_deployment.site_api", shape = "box"]
                "[root] aws_api_gateway_integration.authentication_post" [label = "aws_api_gateway_integration.authentication_post", shape = "box"]
                "[root] aws_api_gateway_integration.users_post" [label = "aws_api_gateway_integration.users_post", shape = "box"]
                "[root] aws_api_gateway_method.authentication_post" [label = "aws_api_gateway_method.authentication_post", shape = "box"]
                "[root] aws_api_gateway_method.users_post" [label = "aws_api_gateway_method.users_post", shape = "box"]
                "[root] aws_api_gateway_method_response.authentication_post_201" [label = "aws_api_gateway_method_response.authentication_post_201", shape = "box"]
                "[root] aws_api_gateway_method_response.authentication_post_400" [label = "aws_api_gateway_method_response.authentication_post_400", shape = "box"]
                "[root] aws_api_gateway_method_response.users_post_201" [label = "aws_api_gateway_method_response.users_post_201", shape = "box"]
                "[root] aws_api_gateway_method_response.users_post_400" [label = "aws_api_gateway_method_response.users_post_400", shape = "box"]
                "[root] aws_api_gateway_resource.authentication" [label = "aws_api_gateway_resource.authentication", shape = "box"]
                "[root] aws_api_gateway_resource.users" [label = "aws_api_gateway_resource.users", shape = "box"]
                "[root] aws_api_gateway_rest_api.site_api" [label = "aws_api_gateway_rest_api.site_api", shape = "box"]
                "[root] aws_iam_role.lambda_role" [label = "aws_iam_role.lambda_role", shape = "box"]
                "[root] aws_lambda_function.authentication" [label = "aws_lambda_function.authentication", shape = "box"]
                "[root] aws_lambda_function.users" [label = "aws_lambda_function.users", shape = "box"]
                "[root] aws_lambda_permission.authentication" [label = "aws_lambda_permission.authentication", shape = "box"]
                "[root] aws_security_group.site_api" [label = "aws_security_group.site_api", shape = "box"]
                "[root] aws_security_group_rule.private_egress_all" [label = "aws_security_group_rule.private_egress_all", shape = "box"]
                "[root] data.aws_s3_bucket_object.s3_build_artifact_bucket" [label = "data.aws_s3_bucket_object.s3_build_artifact_bucket", shape = "box"]
                "[root] data.aws_subnet.private" [label = "data.aws_subnet.private", shape = "box"]
                "[root] data.aws_subnet_ids.private" [label = "data.aws_subnet_ids.private", shape = "box"]
                "[root] data.aws_vpc.vpc" [label = "data.aws_vpc.vpc", shape = "box"]
                "[root] provider.aws" [label = "provider.aws", shape = "diamond"]
                "[root] aws_api_gateway_base_path_mapping.site_api" -> "[root] aws_api_gateway_deployment.site_api"
                "[root] aws_api_gateway_deployment.site_api" -> "[root] aws_api_gateway_integration.authentication_post"
                "[root] aws_api_gateway_deployment.site_api" -> "[root] aws_api_gateway_integration.users_post"
                "[root] aws_api_gateway_integration.authentication_post" -> "[root] aws_api_gateway_method.authentication_post"
                "[root] aws_api_gateway_integration.authentication_post" -> "[root] aws_lambda_function.authentication"
                "[root] aws_api_gateway_integration.users_post" -> "[root] aws_api_gateway_method.users_post"
                "[root] aws_api_gateway_integration.users_post" -> "[root] aws_lambda_function.users"
                "[root] aws_api_gateway_method.authentication_post" -> "[root] aws_api_gateway_resource.authentication"
                "[root] aws_api_gateway_method.users_post" -> "[root] aws_api_gateway_resource.users"
                "[root] aws_api_gateway_method_response.authentication_post_201" -> "[root] aws_api_gateway_method.authentication_post"
                "[root] aws_api_gateway_method_response.authentication_post_400" -> "[root] aws_api_gateway_method.authentication_post"
                "[root] aws_api_gateway_method_response.users_post_201" -> "[root] aws_api_gateway_method.users_post"
                "[root] aws_api_gateway_method_response.users_post_400" -> "[root] aws_api_gateway_method.users_post"
                "[root] aws_api_gateway_resource.authentication" -> "[root] aws_api_gateway_rest_api.site_api"
                "[root] aws_api_gateway_resource.users" -> "[root] aws_api_gateway_rest_api.site_api"
                "[root] aws_api_gateway_rest_api.site_api" -> "[root] provider.aws"
                "[root] aws_iam_role.lambda_role" -> "[root] provider.aws"
                "[root] aws_lambda_function.authentication" -> "[root] aws_iam_role.lambda_role"
                "[root] aws_lambda_function.authentication" -> "[root] data.aws_s3_bucket_object.s3_build_artifact_bucket"
                "[root] aws_lambda_function.users" -> "[root] aws_iam_role.lambda_role"
                "[root] aws_lambda_function.users" -> "[root] aws_security_group.site_api"
                "[root] aws_lambda_function.users" -> "[root] data.aws_s3_bucket_object.s3_build_artifact_bucket"
                "[root] aws_lambda_function.users" -> "[root] data.aws_subnet_ids.private"
                "[root] aws_lambda_permission.authentication" -> "[root] aws_api_gateway_method.authentication_post"
                "[root] aws_lambda_permission.authentication" -> "[root] aws_lambda_function.authentication"
                "[root] aws_security_group.site_api" -> "[root] data.aws_vpc.vpc"
                "[root] aws_security_group_rule.private_egress_all" -> "[root] aws_security_group.site_api"
                "[root] data.aws_s3_bucket_object.s3_build_artifact_bucket" -> "[root] provider.aws"
                "[root] data.aws_subnet.private" -> "[root] data.aws_subnet_ids.private"
                "[root] data.aws_subnet_ids.private" -> "[root] data.aws_vpc.vpc"
                "[root] data.aws_vpc.vpc" -> "[root] provider.aws"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_api_gateway_base_path_mapping.site_api"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_api_gateway_method_response.authentication_post_201"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_api_gateway_method_response.authentication_post_400"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_api_gateway_method_response.users_post_201"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_api_gateway_method_response.users_post_400"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_lambda_permission.authentication"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] aws_security_group_rule.private_egress_all"
                "[root] meta.count-boundary (count boundary fixup)" -> "[root] data.aws_subnet.private"
                "[root] provider.aws (close)" -> "[root] aws_api_gateway_base_path_mapping.site_api"
                "[root] provider.aws (close)" -> "[root] aws_api_gateway_method_response.authentication_post_201"
                "[root] provider.aws (close)" -> "[root] aws_api_gateway_method_response.authentication_post_400"
                "[root] provider.aws (close)" -> "[root] aws_api_gateway_method_response.users_post_201"
                "[root] provider.aws (close)" -> "[root] aws_api_gateway_method_response.users_post_400"
                "[root] provider.aws (close)" -> "[root] aws_lambda_permission.authentication"
                "[root] provider.aws (close)" -> "[root] aws_security_group_rule.private_egress_all"
                "[root] provider.aws (close)" -> "[root] data.aws_subnet.private"
                "[root] root" -> "[root] meta.count-boundary (count boundary fixup)"
                "[root] root" -> "[root] provider.aws (close)"
        }
}
```

In order to convert the outputted dot format to SVG, you can use a tool called graphviz
[http://www.graphviz.org/](http://www.graphviz.org/)

The instructions on the site are quote good, but if you are using windows it's a bit more complicated. There is an installer, but you will have to route out the bin in Program Files and add it to you Environment Path.

Once you've done that, you can pipe into graphwiz to generate an SVG

```
terraform graph | dot -Tsvg > graph.svg
```

For example:

<amp-img src="/assets/img/setting-up-serverless-api-dot-net-core/graph.svg"
  width="1000"
  height="400"
  layout="responsive">
</amp-img>


Theres also another tool which is pretty cool, called blast radius, which is available via a docker image (although this is less safe, since it runs the terraform command for you with your credentials, there must be a way to generate the dot file and upload, but I can't seem to find the documentation for this)

[https://28mm.github.io/blast-radius-docs/](https://28mm.github.io/blast-radius-docs/)

```
docker run --cap-add=SYS_ADMIN -it --rm -p 5000:5000 -v C:\Users\craig.godden-payne\Desktop\terra:/workdir:ro 28mm/blast-radius
```

<amp-img src="/assets/img/terraform-graph/blast-radius.svg"
  width="1000"
  height="400"
  layout="responsive">
</amp-img>
