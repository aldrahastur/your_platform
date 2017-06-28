require 'spec_helper'

feature "Adding a BlogPost", :js do
  include SessionSteps

  background do
    @page = Page.create(title: "My Shiny Page")
  end
  scenario "Adding a blog post" do
    login(:admin)
    visit page_path(@page)

    create_a_new_blog_post "My new blog post"
    within ".box .panel-heading" do
      page.should have_text "My new blog post"
    end
  end

  scenario "(bug fix) one should not be able to create blog posts as child of a blog post" do
    #
    # @apge
    #   |----- @blog_post
    #   |----- @another_blog_post
    #                 |----------- @this_blog_post_is_not_ok
    #
    # When officers look at @another_blog_post and click 'add blog post', they might
    # expect the post to appear as child of @page, but not as child of @another_blog_post.
    # Therefore, we remove the 'add blog post' button in the blog post detail view.
    #
    @another_blog_post = BlogPost.create title: 'Another blog post'
    @page.child_pages << @another_blog_post

    login :admin

    visit page_path(@page)
    page.should have_text I18n.t :new_page

    visit blog_post_path(@another_blog_post)
    page.should have_no_text I18n.t :new_page

    visit page_path(@another_blog_post)
    page.should have_no_text I18n.t :new_page
  end
end
