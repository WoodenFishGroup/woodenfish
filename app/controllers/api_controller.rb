class ApiController < ApplicationController
  include ApplicationHelper
  def users
    @user = User.all.map { |e| {:name => e.name, :username => e.alias, :image => e.avartar} }
    render :json => @user.to_json
  end
end
