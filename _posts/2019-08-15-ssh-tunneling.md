---
layout: post
title: SSH Tunneling
image: /assets/img/ssh-tunneling/cover.png
readtime: 2 minutes
--- 
 
Today i had to connect mysql workbench to a mysql instance hosted within RDS. The rds instance didn't allow public access, and the only way I could connect, would be through a bastion server hosted within the same VPC, then call mysql from there. All this I've done before and is fairly straightforward, but today MFA was enabled on the bastion server, and mysql workbench only supports TCP/IP over SSH, with a key, not a google authenticator code.

I read a few articles on how to hack ssh configs to enable this, and then provide the MFA code, but it just felt a bit wrong. Instead I learned how to create a tunnel from my local machine to the rds server, over SSH, which would allow me to pass my MFA token, then just connect mysql workbench as if it was running on my local machine.

```
ssh -L 3306:my.rds-instance.com:3306 craig.godden-payne@my.bastion-server.com
```

This example opens a connection locally from localhost:3306 to my.rds-instance.com:3306 (which is resolvable from my.bastion-server.com) and connects via my.bastion-server.com
