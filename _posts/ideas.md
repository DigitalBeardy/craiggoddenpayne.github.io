
Downloading a specific version of a file using the aws cli from s3

AWS_PROFILE=iam-ditto-music-qa aws s3api get-object --bucket ditto-music-terraform-state-files --key env:/qa/pattern-library.tfstate --version-id XWDcMb1GOqgp.wU1CKhn_0dTb0JOKC48 output.tfstate

