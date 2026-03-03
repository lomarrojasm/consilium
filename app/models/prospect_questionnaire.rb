class ProspectQuestionnaire < ApplicationRecord
  # Método para obtener las preguntas (reutiliza el helper que ya tienes)
  def categorized_questions
    # Aquí puedes llamar al helper que ya usas en la vista:
    # ApplicationController.helpers.get_autodiagnostico_questions
    # O simplemente definir la lógica aquí.
  end

  # Agrega un método para calcular promedios si la vista los usa
  def scores_by_category
    # Lógica que suma y promedia las respuestas en 'answers'
  end
end