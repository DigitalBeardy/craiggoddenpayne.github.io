---
layout: post
title: Javascript call and apply
image: /assets/img/2015-12-27-javascript-call-and-apply/js.jpg
readtime: 6 minutes
---

Call and apply, it's all about "this" and setting the context when inside a function. It's important to know how and why you would need to do this, especially if you are using a pattern such as MVP when writing larger quantities of javascript, e.g. in a website or a node.js project, and you want to maintain readability and maintainability.


In this post, I'm going to attempt to explain the functionality and uses for the javascript method "call". and "apply". The "call" and "apply" methods are built into javascript, so they can be used in node.js, websites etc.



The call and apply methods are useful for when you want to call a function, but replace the context keyword "this" inside the function with a specified parameter. You cannot normally change the value of this, as it is not a real variable, but you can swap its context out by using "call" or "apply".



One thing to remember though, if you are in "non-strict" mode, and the value of the first argument is null or undefined, it will be replaced with the global object. (in a browser, this will be window). You will find this technique especially useful if you are creating a function that has some kind of state, and needs to refer to itself.



The difference between call and apply are just down to developer preference. Call takes a variable for each parameter, and apply uses an array as a variable for all parameters.



Here's an example of where using call is useful.

When making an ajax call, you lose the state of "this" on the call back, but sometimes you may want to maintain the context after a callback. When GetAddress is called, we set "this" to the variable self, and once get has completed, we use "call" to pass "self" to the method, which will swap out "this".



This means, when the callback function is executed, we still have the "this" value as you have expected in a synchronous call.


```js
function Employee(id, firstName, surname) {
  this.Surname = surname;
  this.FirstName = firstname;
  this.Id = id;
};

Employee.prototype = (function() {
  var getAddress = function(callback) {
    var self = this;
    $.get('/employees/address/' + this.id, function(data) {
      callback && callback.call(self, data.address);
    });
  };
  return {
    GetAddress: getAddress
  }
})();

var employee = new Employee(1, 'Craig', 'Godden-Payne');
employee.GetAddress(function(address) {
  alert('Employees address is ' + this.FirstName + ' belongs to ' + address);
});
```




Apply can be used in the same way, but instead of passing variables to the function, it passes the context and the variables as an array.





