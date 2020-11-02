---
layout: post
title: You are being redirected...
image: /assets/img/redirect.png
readtime: 0 seconds
---

# You are being redirected

<script>
    function getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    };
    window.location.href = "https://" + getUrlParameter('redirect');
</script>