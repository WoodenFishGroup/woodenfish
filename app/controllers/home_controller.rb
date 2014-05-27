require 'json'

class HomeController < LoginController

  def save_profile
    new_post = params[:new_post] == '1'
    new_comment = params[:new_comment] == '1'
    summary = params[:summary] == '1'
    time_in_day = params[:time].to_i * 3600 - get_timezone_offset(params[:timezone])
    notification = {
        :new_post => new_post,
        :new_comment => new_comment,
        :summary => {
          :enabled => summary,
          :time_in_day => time_in_day
        }
    }.to_json
    avartar = params[:avartar]
    User.update(get_current_user_id, :avartar => avartar, :notification => notification)
    redirect_to root_path
  end

end
