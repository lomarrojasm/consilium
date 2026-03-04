class ClientsController < ApplicationController
  # Asegura que se use el layout del dashboard
  layout "application"
  
  # Seguridad: Solo usuarios logueados pueden ver esto
  before_action :authenticate_user!
  
  # Callback para encontrar el cliente en acciones específicas
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients
  def index
    # Ordenamos por nombre de empresa para facilitar la búsqueda
    @clients = Client.all.order(company_name: :asc)
  end

  # GET /clients/1
  def show
    @client = Client.find(params[:id])
    
    # 1. Preparamos la consulta base (optimizada con includes)
    base_query = @client.conversations.includes(:sender, :recipient, :messages).order(updated_at: :desc)

    # 2. Aplicamos el filtro de seguridad según el rol
    if current_user.role == 'admin'
      # El Admin ve TODO (modo moderador)
      @conversations = base_query
    else
      # El usuario normal solo ve SUS conversaciones
      @conversations = base_query.involving(current_user)
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "Cliente creado exitosamente."
    else
      # Rails 8 requiere status: :unprocessable_entity para renderizar errores correctamente
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      redirect_to clients_path, notice: "Cliente actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Cliente eliminado.", status: :see_other
  end

  def timeline
    @client = Client.find(params[:id])
    
    # 1. Base: Buscamos solo en la tabla de Logs de este cliente
    @events = TimelineLog.where(client: @client)

    # 2. Filtro de TEXTO (params[:query])
    # Como el 'concern' guarda el nombre del proyecto o mensaje en la columna 'details',
    # solo necesitamos buscar ahí.
    if params[:query].present?
      @events = @events.where("details LIKE ?", "%#{params[:query]}%")
    end

    # 3. Filtro de FECHA (params[:search_date])
    if params[:search_date].present?
      # Si el usuario eligió un día específico
      @events = @events.where(happened_at: params[:search_date].to_date.all_day)
    
    elsif params[:query].blank?
      # CASO DEFAULT: Si no hay búsqueda de texto ni fecha, mostrar solo el MES seleccionado
      @selected_date = params[:month] ? Date.parse(params[:month]) : Date.today
      range = @selected_date.beginning_of_month..@selected_date.end_of_month
      @events = @events.where(happened_at: range)
    end

    # 4. Ordenar (Lo más nuevo arriba)
    @events = @events.order(happened_at: :desc)
  end

  

  private

    # Busca el cliente por ID
    def set_client
      @client = Client.find(params[:id])
    end

    # Strong Parameters: Lista blanca de todos los campos permitidos
    def client_params
      params.require(:client).permit(
        # --- Datos Generales ---
        :company_name, 
        :trade_name, 
        :rfc, 
        :corporate_regime, 
        :tax_regime, 
        :type_taxpayer,
        :industry, 
        :country,
        :web_page,
        :social_network,
        :avatar,
        :membership,

        # --- Dirección Fiscal ---
        :tax_street, 
        :tax_no_ext, 
        :tax_no_int, 
        :tax_suburb, 
        :tax_cp, 
        :tax_city, 
        :tax_town_hall,

        # --- Dirección Operativa ---
        :oper_street, 
        :oper_no_ext, 
        :oper_no_int, 
        :oper_suburb, 
        :oper_cp, 
        :oper_city, 
        :oper_town_hall,

        # --- Datos Operativos ---
        :operation_year, 
        :total_employee, 
        :total_location, 
        :product_service,

        # --- Contacto: Sponsor ---
        :sponsor_name, 
        :sponsor_position, 
        :sponsor_cel, 
        :sponsor_email,

        # --- Contacto: Representante Legal ---
        :legal_representative_name, 
        :legal_representative_position, 
        :legal_representative_cel, 
        :legal_representative_email,

        # --- Contacto: Operaciones ---
        :operation_name, 
        :operation_position, 
        :operation_cel, 
        :operation_email,

        # --- Contacto: Finanzas / Contabilidad ---
        :finance_accounting_name, 
        :finance_accounting_position, 
        :finance_accounting_cel, 
        :finance_accounting_email,

        # --- Contacto: RRHH ---
        :rrhh_name, 
        :rrhh_position, 
        :rrhh_cel, 
        :rrhh_email,

        # --- Contacto: Comercial ---
        :comercial_name, 
        :comercial_position, 
        :comercial_cel, 
        :comercial_email,

        # --- Sistemas Actuales ---
        :erp_system, 
        :accounting_system, 
        :rrhh_system, 
        :crm_system, 
        :storage_system,

        # --- Objetivo del Proyecto / Problema ---
        :main_issue, 
        :project_objective, 
        :deadline, 
        :internal_responsible_name, 
        :internal_responsible_contact
      )
    end
end