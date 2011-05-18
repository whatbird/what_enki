class PostsController < ApplicationController
  include UrlHelper

  def index
    @tag = params[:tag]
    @posts = Post.find_recent(:tag => @tag, :include => :tags)

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end
  end

  def show
    begin
      @post = Post.find_by_permalink(*([:year, :month, :day, :slug].collect {|x| params[x] } << {:include => [:approved_comments, :tags]}))
    rescue
      post = Post.find_by_slug!(params[:slug], :include => [:approved_comments, :tags])
      redirect_to post_path(post), :status => :moved_permanently
    end
    @comment = Comment.new
  end
end
