class Api::V1::CommentsController < Api::V1::BaseController

  expose :parent_post, -> { Post.find params[:parent_post_id] if params[:parent_post_id].present? }

  def create
    raise 'no parent post present' unless parent_post
    authorize! :create_comment, parent_post

    new_comment = parent_post.comments.create! comment_params.merge({author_user_id: current_user.id})
    parent_post.touch

    new_comment.deliver_later

    render json: new_comment, status: :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:text)
  end

end
