class ProjectCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  # Redirección de seguridad
  def index
    redirect_to client_project_path(@project.client, @project)
  end
  
  def create
    @comment = @project.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      # El modelo ProjectComment se encarga de crear las notificaciones (after_create)
      redirect_to client_project_path(@project.client, @project), notice: "Comentario agregado."
    else
      redirect_to client_project_path(@project.client, @project), alert: "Error: No se pudo agregar el comentario."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def comment_params
    # IMPORTANTE: Permitimos recipient_id para las menciones/privados
    params.require(:project_comment).permit(:body, :recipient_id) 
  end
end