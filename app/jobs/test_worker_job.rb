class TestWorkerJob < ApplicationJob
  queue_as :default

  def perform(nombre = "Luis")
    puts "----------------------------------------------------"
    puts "🚀 ¡TRABAJO EJECUTADO CON ÉXITO PARA: #{nombre}!"
    puts "----------------------------------------------------"
  end
end