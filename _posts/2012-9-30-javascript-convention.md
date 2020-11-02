---
layout: post
title: Javascript Convention
image: /assets/img/2012-9-30-javascript-convention/js.jpg
readtime: 6 minutes
---

I've been writing my js13k submission whenever i have had chance over the last few days, and it's made me think more about the way i write javascript.


I haven't has much experience in my working life with javascript, i've dabbled here and there (moreso in my current role). I've read multiple design patterns that can be implemented using javascript, but i still tend to write javascript in an oop style, asd i just find it easier to follow. I always think separation of concern is the most important thing to start of with; I find that if you don't start separating things out at the earliest stages, the code you write becomes more and more unmanageable as you write it.


The way i like to write javascript - using IOC where possible: This is what i call a View Controller pattern, it separates the view code (if using jQuery etc.) and the controller. It makes testing of the code very easy, you only really need to assert that methods were called on the controller, then test the view separately.



I have tried to apply this pattern to my js13k game, but since I haven't had much experience with game code (I spend 99% of my time writing business logic etc.) it kind of follows, but not really strictly. Plus normally I would write test driven, thats probably where the game went wrong!!

```js
function View(){  
    return {  
      getSomeValue: function(){  
        return $("idOfElement").val();  
      },  
      setSomeValue: function(value){  
        $("idOfElement").val(value);  
      }  
    };  
  }  
  function Controller(view){  
    Controller.prototype = this;  
    Controller.prototype.view = view;  
  }  
  Controller.prototype.Initialise = function(){  
    //constructor code  
    var controller = Controller.prototype;  
    controller.SomeValueChanged();  
  }  
  Controller.prototype.SomeValueChanged = function(){  
    var view = Controller.prototype.view;  
    view.setSomeValue("value");  
  }  
  domReady(function(){  
    var view = new View();  
    var controller = new Controller(view);  
    controller.Initialise();  
});  
```