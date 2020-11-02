S3 and CloudFront signed URLs both solve the same problem or allowing access to a user to a private url.

The main difference is with cloudfront the path is the user access, and with s3 the request looks like it came from the iam user who signed the request.

Cloudfront urls have to be signed using the root user using a cloudfront keypair, whereas S3 is signed by any IAM user.

When revoking signed urls, in cloudfront you would distrust the keypair, where in s3 you would revoke the permission.

In cloudfront you need a separate account to allow different paths to have access to different permissions, in S3 you would do this through different Iam users, and permissions are set using policies

S3 Signed cookie / SignedLink https://docs.aws.amazon.com/AmazonS3/latest/dev/ShareObjectPreSignedURLDotNetSDK.html

Pro

Con

Similar approach to signed url

Gaining access to cookie gains access to all bucket files.

One cookie for multiple files

We can’t easily audit

Restrict by IP / DateTime

Signed on the client

Cloudfront Signed cookiehttps://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-cookies.html

Pro

Con

Similar approach to signed url

Gaining access to cookie gains access to all bucket files.

One cookie for multiple files

Restrict by IP / DateTime

Set-Cookie: Domain=d111111abcdef8.cloudfront.net; Path=/; Secure; HttpOnly; CloudFront-Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cDovL2QxMTExMTFhYmNkZWY4LmNsb3VkZnJvbnQubmV0L2dhbWVfZG93bmxvYWQuemlwIiwiQ29uZGl0aW9uIjp7IklwQWRkcmVzcyI6eyJBV1M6U291cmNlSXAiOiIxOTIuMC4yLjAvMjQifSwiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE0MjY1MDAwMDB9fX1dfQ__
Set-Cookie: Domain=d111111abcdef8.cloudfront.net; Path=/; Secure; HttpOnly; CloudFront-Signature=dtKhpJ3aUYxqDIwepczPiDb9NXQ_
Set-Cookie: Domain=d111111abcdef8.cloudfront.net; Path=/; Secure; HttpOnly; CloudFront-Key-Pair-Id=APKA9ONS7QCOWEXAMPLE

Cloudfront Secure link https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PrivateCFSignatureCodeAndExamples.html

{
   "Statement": [
      {
         "Resource":"URL or stream name of the file",
         "Condition":{
            "DateLessThan":{"AWS:EpochTime":required ending date and time in Unix time format and UTC},
            "DateGreaterThan":{"AWS:EpochTime":optional beginning date and time in Unix time format and UTC},
            "IpAddress":{"AWS:SourceIp":"optional IP address"}
         }
      }
   ]
}

Pro

Con

Similar approach to signed cookie

A separate link is created to your s3 link

You can restrict the link to very tight requirements

Each file would need to be remotely signed JIT

We can audit requests to create secure link

Restrict by IP / DateTime

Securing the S3 bucket to a referrer or some other kind of policy:

{
	"Version": "2012-10-17",
	"Id": "http referer policy example",
	"Statement": [
		{
			"Sid": "Allow get requests originating from www.domain.com and domain.com.",
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::my-bucket/documents/*",
			"Condition": {
				"StringLike": {
					"aws:Referer": [
						"https://portswigger.net/"
					]
				}
			}
		}

Pro

Con

Easy to setup

Very easy to spoof header, not secure

No maintenance

Same with other restrictions, like IP Address etc.

