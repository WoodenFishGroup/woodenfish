require 'digest/md5'

class HomeController < ApplicationController
  def index
    @posts = Post.where("id > 0").paginate(:page => params[:page], :per_page => 20).order("id DESC")
  end
end
