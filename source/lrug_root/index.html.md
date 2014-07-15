--- 
published_at: 2006-09-04 23:00:00 Z
updated_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
title: LRUG
created_at: 2006-09-05 11:38:34 Z
slug: /
breadcrumb: Home
parts: 
- sidebar
updated_at: 2014-06-09 13:15:18 Z
status: Published
created_by: 
  email: james@lazyatom.com
  login: lazyatom
  name: James Adam
class_name: ""
---

<r:find url="/meetings/">

<r:children:each limit="1" order="desc">
<div class="first entry">
  <h2><r:link /></h2>
  <r:snippet name="sponsors" />
  <r:content />
  <r:if_content part="extended"><r:link anchor="extended">Continue Reading&#8230;</r:link></r:if_content>
  <p class="info">Posted by <r:author /> on <r:date format="%b %d, %Y" /></p>
</div>
</r:children:each>

<r:children:each limit="2" offset="1" order="desc">
<div class="entry">
  <h2><r:link /></h2>
  <r:snippet name="sponsors" />
  <r:content />
  <r:if_content part="extended"><r:link anchor="extended">Continue Reading&#8230;</r:link></r:if_content>
  <p class="info">Posted by <r:author /> on <r:date format="%b %d, %Y" /></p>
</div>
</r:children:each>

</r:find>

