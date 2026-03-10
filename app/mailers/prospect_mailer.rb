# app/mailers/prospect_mailer.rb
class ProspectMailer < ApplicationMailer
  # Esto permite usar los métodos dentro de las vistas (.erb)
  helper QuestionnaireHelper 
  
  # Esto permite usar los métodos aquí mismo, en la lógica del Mailer (.rb)
  include QuestionnaireHelper 

  def membership_result(questionnaire)
    @questionnaire = questionnaire
    
    # Calculamos el puntaje
    answers = @questionnaire.answers || {}
    @total_score = answers.select { |k, _| k.to_s.start_with?('m') }.values.map(&:to_i).sum
    
    # Ahora el método 'get_membership_level' ya será reconocido
    @membership_level = get_membership_level(@total_score)
    
    mail(
      to: @questionnaire.email,
      bcc: "omar.rojas@ligoconsulting.com",
      subject: "Consilium: Tu perfil operativo y recomendación de membresía"
    )
  end
end