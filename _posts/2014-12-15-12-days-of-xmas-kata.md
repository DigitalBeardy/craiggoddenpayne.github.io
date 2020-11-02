---
layout: post
title: 12 days of xmas kata
image: /assets/img/2014-12-15-12-days-of-xmas-kata/xmas.gif
readtime: 4 minutes
---

I found a nice seasonal challenge for the end of the year - printing out the lyrics to the '12 Days of Christmas':

- On the twelfth day of Christmas,
- My true love gave to me,
- Twelve drummers drumming,
- Eleven pipers piping,
- Ten lords-a-leaping,
- Nine ladies dancing,
- Eight maids-a-milking,
- Seven swans-a-swimming,
- Six geese-a-laying,
- Five golden rings,
- Four calling birds,
- Three french hens,
- Two turtle doves,
- And a partridge in a pear tree.

### Rules

You don't have to worry about capitalization; the entire text can be case insensitive
You can sensibly ignore any punctuation: hyphens can be spaces, and commas and periods can be ignored
There should be a blank line between each verse
You must ordinalize your numbers: "first day of Christmas", "Four calling birds", etc


Here is my submission

```js
    function Christmas(){}
    Christmas.prototype = (function(){
        var ordinalizeNumber = function(){
            return ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth"];
        }
        var numberAsString = function(){
            return ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve"];
        }
        var gifts = function(){
            return ["a partridge in a pear tree", "turtle doves", "french hens", "calling birds", "golden rings", "geese-a-laying", "swans-a-swimming", "maids-a-milking", "ladies dancing", "lords-a-leaping", "pipers piping", "drummers drumming"];
        }
        var br = "<br />";
        var print = function(){
            var lines = [];
            for(var i=0; i < 12; i++){
                lines[lines.length] = "On the " + ordinalizeNumber()[i] + " day of christmas," + br;
                lines[lines.length] = "My true love gave to me," + br;
                var moreThanOneGift = i > 0;
                if(!moreThanOneGift){
                    lines[lines.length] = gifts()[0] + "." + br + br;
                    continue;
                }
                for(var giftNumber =i; giftNumber >=0; giftNumber--){
                    lines[lines.length] = numberAsString()[giftNumber] + " " + gifts()[giftNumber] + "," + br;
                    if(giftNumber == 0)
                        lines[lines.length-1] = lines[lines.length-1].replace("One", "And");
                }
                lines[lines.length] = br;
            }
            return lines;
        };

        return {Print:print};
    })();

    var christmas = new Christmas();
    var lines = christmas.Print();
    for(var lineNumber = 0; lineNumber < lines.length; lineNumber++){
        document.writeln(lines[lineNumber]);
    }

```