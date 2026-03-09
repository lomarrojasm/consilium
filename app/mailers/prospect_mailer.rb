# app/mailers/prospect_mailer.rb
class ProspectMailer < ApplicationMailer
  default from: 'hola@consilium.com' # Cambia por tu correo real

  def membership_result(questionnaire)
    @questionnaire = questionnaire
    
    # Calculamos el puntaje para usarlo en el correo si lo deseas
    @total_score = @questionnaire.answers.select { |k, v| k.start_with?('m') }.values.map(&:to_i).sum
    @membership_level = ApplicationController.helpers.get_membership_level(@total_score)
    
    mail(
      to: @questionnaire.email,
      subject: "Consilium: Tu perfil operativo y recomendación de membresía"
    )
  end
end