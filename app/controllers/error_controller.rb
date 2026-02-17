class ErrorController < ApplicationController
  layout :choose_layout

  def choose_layout
    action_name == "error_404_alt" ? "vertical" : "base"
  end

  def error_404
  end

  def error_404_alt
  end

  def error_500
  end
end
