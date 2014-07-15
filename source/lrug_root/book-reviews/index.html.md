--- 
created_at: 2007-05-25 09:30:44 Z
published_at: 2007-05-25 00:00:00 Z
status: Published
slug: book-reviews
updated_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
parts: 
- sidebar
class_name: ArchivePage
created_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
breadcrumb: Book Reviews
updated_at: 2013-02-23 13:58:46 Z
---

LRUG members occasionally write book reviews of Ruby books.  We're collecting them here.

<r:children:each limit="5" order="desc">
<div class="entry">
  <h3><r:link /></h3>
  <r:content />
  <r:if_content part="extended"><r:link anchor="extended">Continue Reading&#8230;</r:link></r:if_content>
  <p class="info">Posted by <r:author /> on <r:date format="%b %d, %Y" /></p>
</div>
</r:children:each>
