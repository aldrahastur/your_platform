class BlogsController < PagesController #ApplicationController

  def show
    authorize! :read, page

    @blog_root_page = @blog ||= page
    @blog_posts = @blog.blog_entries.visible_to(current_user)
    @tags = @blog_posts.collect { |entry| entry.tags }.flatten.uniq.sort_by(&:taggings_count).reverse

    set_current_navable @blog_root_page
    set_current_title @blog_root_page.title
  end

  def update
    authorize! :update, page

    params[:page] ||= params[:blog]
    params[:blog] ||= params[:page]
    @page ||= @blog
    @blog ||= page
    super
  end

end