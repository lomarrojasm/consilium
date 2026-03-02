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
            # Permitimos :notes además del :status
            if @questionnaire.update(questionnaire_params)
                redirect_to admin_prospect_questionnaire_path(@questionnaire), notice: "Notas y estatus actualizados correctamente."
            else
                render :show, alert: "No se pudieron guardar los cambios."
            end
        end

        def destroy
            @questionnaire.destroy
            redirect_to admin_prospect_questionnaires_path, notice: "Diagnóstico eliminado correctamente."
        end


        private

        def set_questionnaire
            @questionnaire = ProspectQuestionnaire.find(params[:id])
        end

        def questionnaire_params
            params.permit(:status, :notes)
        end
    end
end