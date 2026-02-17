class ProjectMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  #Autorozacoión de usuarios
  before_action :authorize_project_member!

  def create
    @project_member = @project.project_members.build(member_params)
    @project_member.added_by = current_user
    
    if @project_member.save
      redirect_to client_project_path(@client, @project), notice: 'Miembro agregado al equipo.'
    else
      redirect_to client_project_path(@client, @project), alert: 'Error al agregar miembro. Verifica que no esté repetido.'
    end
  end

  def destroy
    @member = @project.project_members.find(params[:id])
    @member.destroy
    redirect_to client_project_path(@client, @project), notice: 'Miembro eliminado del proyecto.'
  end

  private

  def set_context
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
  end

  def member_params
    params.require(:project_member).permit(:user_id, :role)
  end
end