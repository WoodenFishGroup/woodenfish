require 'digest/md5'

class HomeController < LoginController
  def index
    @posts = Post.where("is_deleted=0").paginate(:page => params[:page], :per_page => 20).order("id DESC")
  end

  def health_check
  end
end
