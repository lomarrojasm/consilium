class PagesController < ApplicationController
  # IMPORTANTE: Permitir ver esta página sin estar logueado
  skip_before_action :authenticate_user!, only: [:logout_success]

  layout :choose_layout

  def logout_success
    # Forzamos el layout limpio que usamos para el login
    render layout: "devise"
  end

  def choose_layout
    action_name == "maintenance" ? "base" : "vertical"
  end

  def faq
  end

  def invoice
  end

  def maintenance
  end

  def preloader
  end

  def pricing
  end

  def profile
  end

  def profile_2
  end

  def starter
  end

  def timeline
  end

end
