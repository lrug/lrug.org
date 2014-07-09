--- 
parts: 
- sidebar
updated_at: 2014-06-09 13:15:18 Z
creatd_by: 
  login: lazyatom
  email: james@lazyatom.com
  name: James Adam
slug: /
created_at: 2006-09-05 11:38:34 Z
breadcrumb: Home
published_at: 2006-09-04 23:00:00 Z
status: Published
class_name: ""
updated_by: 
  login: hlame
  email: murray.steele@gmail.com
  name: Murray Steele
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

