Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '1cm',
      right: '1cm',
      bottom: '1cm',
      left: '1cm'
    },
    user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    # Esto es vital para tus gráficas: espera a que no haya tráfico de red (JS cargado)
    wait_until: 'networkidle0', 
    print_background: true, # Para que se vean tus círculos y degradados
    display_header_footer: false
  }
end