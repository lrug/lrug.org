--- 
published_at: 2007-05-25 00:00:00 Z
updated_by: 
  email: murray.steele@gmail.com
  name: Murray Steele
title: Book Reviews
created_at: 2007-05-25 09:30:44 Z
parts: 
  sidebar: 
    :content: |
      ### All Reviews
      <% book_reviews.each.with_index do |review, idx| %>
      <%= idx %>. <%= link_to review.data.title, review %>
      <% end %>

    :filter: .md
updated_at: 2013-02-23 13:58:46 Z
status: Published
created_by: 
  email: murray.steele@gmail.com
  name: Murray Steele
---

LRUG members occasionally write book reviews of Ruby books.  We're collecting them here.
