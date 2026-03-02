class ProspectQuestionnaire < ApplicationRecord
  # Si tu columna es de tipo TEXT, necesitas esta línea:
  #serialize :answers, coder: JSON
  
  # Si tu columna ya es de tipo JSON o JSONB en Postgres/MySQL, 
  # esta línea no es necesaria, pero no estorba.
end