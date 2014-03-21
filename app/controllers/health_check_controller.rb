class HealthCheckController < ApplicationController
  def health_check
    render :text => "ok"
  end
end
