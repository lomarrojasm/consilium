module Admin
    class ProspectQuestionnairesController < ApplicationController
        helper QuestionnaireHelper
        layout "application"
        before_action :set_questionnaire, only: [:show, :update, :destroy]

        def index
        @questionnaires = ProspectQuestionnaire.all.order(created_at: :desc)
        end

        def show
        # Aquí es donde leerás las 30 respuestas
        end

        def update
            @questionnaire = ProspectQuestionnaire.find(params[:id])
            
            # IMPORTANTE: Usamos questionnaire_params, NO params a secas
            if @questionnaire.update(questionnaire_params)
            redirect_to admin_prospect_questionnaire_path(@questionnaire), notice: 'Actualizado correctamente.'
            else
            redirect_to admin_prospect_questionnaire_path(@questionnaire), alert: 'Hubo un error al guardar.'
            end
        end

        def destroy
            @questionnaire = ProspectQuestionnaire.find(params[:id])
            
            # Guardamos el nombre para el mensaje de éxito
            company_name = @questionnaire.company_name
            
            if @questionnaire.destroy
                # En Rails 8 (Turbo), las redirecciones tras un delete requieren status: :see_other (303)
                redirect_to admin_prospect_questionnaires_path, 
                            notice: "El diagnóstico de #{company_name} fue eliminado correctamente.", 
                            status: :see_other
            else
                redirect_to admin_prospect_questionnaires_path, 
                            alert: "Hubo un error al intentar eliminar el diagnóstico."
            end
            end


        private

        def set_questionnaire
            @questionnaire = ProspectQuestionnaire.find(params[:id])
        end

        def questionnaire_params
            params.require(:prospect_questionnaire).permit(:notes, :status)
        end
    end
end