# app/mailers/prospect_mailer.rb
class ProspectMailer < ApplicationMailer
  # Ya no necesita el 'default from' aquí si está en ApplicationMailer

  def membership_result(questionnaire)
    @questionnaire = questionnaire
    
    # Calculamos el puntaje
    answers = @questionnaire.answers || {}
    @total_score = answers.select { |k, _| k.to_s.start_with?('m') }.values.map(&:to_i).sum
    
    # Usamos el helper para obtener el nivel
    @membership_level = view_context.get_membership_level(@total_score)
    
    mail(
      to: @questionnaire.email,
      subject: "Consilium: Tu perfil operativo y recomendación de membresía"
    )
  end
end