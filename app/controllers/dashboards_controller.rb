class DashboardsController < ApplicationController
  # 1. OBLIGAR AUTENTICACIÓN
  # Si el usuario no está logueado, Devise lo redirige al Login automáticamente.
  before_action :authenticate_user!
  
  def analytics
  end

  def crm
  end

  def index
  end

  def projects
  end

  def wallet
  end
end
