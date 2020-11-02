---
layout: post
title: Capture the flag javascript challenges 1 to 4
image: /assets/img/ringzer0/cover.png
readtime: 10 minutes
---

I've been playing more of the challenges on the ringzer0 website, but this time looking at the javascript challenges. Here is how I solved the first 4 challenges.

https://ringzer0ctf.com/challenges

### Challenge 1 - Client side validation is so secure?

I checked the script on the page and noticed the following:

```
$(".c_submit").click(function(event) {
            event.preventDefault()
            var u = $("#cuser").val();
            var p = $("#cpass").val();
            if(u == "admin" && p == String.fromCharCode(74,97,118,97,83,99,114,105,112,116,73,115,83,101,99,117,114,101)) {
                if(document.location.href.indexOf("?p=") == -1) {   
                    document.location = document.location.href + "?p=" + p;
                }
            } else {
                $("#cresponse").html("<div class='alert alert-danger'>Wrong password sorry.</div>");
            }
        });
```

So I ran the suspicious password check in the console

```
String.fromCharCode(74,97,118,97,83,99,114,105,112,116,73,115,83,101,99,117,114,101)
```

Which returned `JavaScriptIsSecure`

So I logged in with user `admin` and password `JavaScriptIsSecure`

### Challenge 2 - Is hashing more secure?

I checked the script again on the page

```
$(".c_submit").click(function(event) {
    event.preventDefault();
    var p = $("#cpass").val();
    if(Sha1.hash(p) == "b89356ff6151527e89c4f3e3d30c8e6586c63962") {
        if(document.location.href.indexOf("?p=") == -1) {   
            document.location = document.location.href + "?p=" + p;
        }
    } else {
        $("#cresponse").html("<div class='alert alert-danger'>Wrong password sorry.</div>");
    }
});		
```

I copied the sha1 hash, and used an online service to reverse lookup the hash

```
https://md5hashing.net/hash/sha1/b89356ff6151527e89c4f3e3d30c8e6586c63962
```

The captcha made me find cats!!

<amp-img src="/assets/img/ctf-javascript/cats.PNG"
  width="456"
  height="609"
  layout="responsive">
</amp-img>

anyway, the hash matches `adminz`, so I logged in using the password `adminz`

### Challenge 3 - Then obfuscation is more secure?

Again I found the script embedded on the page

```
var _0xc360=["\x76\x61\x6C","\x23\x63\x70\x61\x73\x73","\x61\x6C\x6B\x33","\x30\x32\x6C\x31","\x3F\x70\x3D","\x69\x6E\x64\x65\x78\x4F\x66","\x68\x72\x65\x66","\x6C\x6F\x63\x61\x74\x69\x6F\x6E","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x27\x65\x72\x72\x6F\x72\x27\x3E\x57\x72\x6F\x6E\x67\x20\x70\x61\x73\x73\x77\x6F\x72\x64\x20\x73\x6F\x72\x72\x79\x2E\x3C\x2F\x64\x69\x76\x3E","\x68\x74\x6D\x6C","\x23\x63\x72\x65\x73\x70\x6F\x6E\x73\x65","\x63\x6C\x69\x63\x6B","\x2E\x63\x5F\x73\x75\x62\x6D\x69\x74"];$(_0xc360[12])[_0xc360[11]](function (){var _0xf382x1=$(_0xc360[1])[_0xc360[0]]();var _0xf382x2=_0xc360[2];if(_0xf382x1==_0xc360[3]+_0xf382x2){if(document[_0xc360[7]][_0xc360[6]][_0xc360[5]](_0xc360[4])==-1){document[_0xc360[7]]=document[_0xc360[7]][_0xc360[6]]+_0xc360[4]+_0xf382x1;} ;} else {$(_0xc360[10])[_0xc360[9]](_0xc360[8]);} ;} );
```

I haven't seen anything like this before, but I googled javascript unofuscate and found a nice tool to deobfuscate the javascript

```
http://jsnice.org/
```

So now I have this, which isn't as bad

```
'use strict';
/** @type {!Array} */
var _0xc360 = ["val", "#cpass", "alk3", "02l1", "?p=", "indexOf", "href", "location", "<div class='error'>Wrong password sorry.</div>", "html", "#cresponse", "click", ".c_submit"];
$(_0xc360[12])[_0xc360[11]](function() {
  var _oldCopyrightNotice = $(_0xc360[1])[_0xc360[0]]();
  var _thisYear = _0xc360[2];
  if (_oldCopyrightNotice == _0xc360[3] + _thisYear) {
    if (document[_0xc360[7]][_0xc360[6]][_0xc360[5]](_0xc360[4]) == -1) {
      document[_0xc360[7]] = document[_0xc360[7]][_0xc360[6]] + _0xc360[4] + _oldCopyrightNotice;
    }
  } else {
    $(_0xc360[10])[_0xc360[9]](_0xc360[8]);
  }
});
```

Its still quite complex, so I tried a different tool 

```
https://lelinhtinh.github.io/de4js/
```

Which outputted 

```
$('.c_submit')['click'](function () {
    var _0xf382x1 = $('#cpass')['val']();
    var _0xf382x2 = 'alk3';
    if (_0xf382x1 == '02l1' + _0xf382x2) {
        if (document['location']['href']['indexOf']('?p=') == -1) {
            document['location'] = document['location']['href'] + '?p=' + _0xf382x1;
        };
    } else {
        $('#cresponse')['html']('<div class=\'error\'>Wrong password sorry.</div>');
    };
});
```

So the if statement is based on `'02l1' + _0xf382x2` which is `02l1alk3` 

It worked!

### Challenge 4 - Most Secure Crypto Algo

Again, script embedded in page

```

			$(".c_submit").click(function(event) {
				event.preventDefault();
				var k = CryptoJS.SHA256("\x93\x39\x02\x49\x83\x02\x82\xf3\x23\xf8\xd3\x13\x37");
				var u = $("#cuser").val();
				var p = $("#cpass").val();
				var t = true;
			
				if(u == "\x68\x34\x78\x30\x72") {
					if(!CryptoJS.AES.encrypt(p, CryptoJS.enc.Hex.parse(k.toString().substring(0,32)), { iv: CryptoJS.enc.Hex.parse(k.toString().substring(32,64)) }) == "ob1xQz5ms9hRkPTx+ZHbVg==") {
						t = false;
					}
				} else {
					$("#cresponse").html("<div class='alert alert-danger'>Wrong password sorry.</div>");
					t = false;
				}
				if(t) {
					if(document.location.href.indexOf("?p=") == -1) {
						document.location = document.location.href + "?p=" + p;
               			}
				}
			});
		
```

I first decoded the hex username `\x68\x34\x78\x30\x72` to `h4x0r`

Then I resolved what k would equate to

```
CryptoJS.SHA256("\x93\x39\x02\x49\x83\x02\x82\xf3\x23\xf8\xd3\x13\x37")
```

which is 

```
d8439507642eb76a4050adb27891d38a01fdb35ac5309d45a99f89c0a4ca0db6
```

the key is being used in two parts, `d8439507642eb76a4050adb27891d38a` for the key and `01fdb35ac5309d45a99f89c0a4ca0db6` for the initialisation vector

Since we have the value `ob1xQz5ms9hRkPTx+ZHbVg==` available, we can just decrypt it, by reversing the logic.

e.g.

```
CryptoJS.AES.encrypt(p, CryptoJS.enc.Hex.parse(k.toString().substring(0,32)), { iv: CryptoJS.enc.Hex.parse(k.toString().substring(32,64)) }) == "ob1xQz5ms9hRkPTx+ZHbVg=="
```

can be rewritten as

```
CryptoJS.AES.decrypt("ob1xQz5ms9hRkPTx+ZHbVg==", CryptoJS.enc.Hex.parse(k.toString().substring(0,32)), { iv: CryptoJS.enc.Hex.parse(k.toString().substring(32,64)) }).toString()
```

which is `50617373573052442132383925212a`, which converted from hex to string is `PassW0RD!289%!*`

So I log in with `h4x0r` and `PassW0RD!289%!*`