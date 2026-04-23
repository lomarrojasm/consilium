Rails.application.routes.draw do
  # =========================================================================
  # 0. HEALTH CHECK
  # =========================================================================
  get "up" => "rails/health#show", as: :rails_health_check

  # =========================================================================
  # 1. NAVEGACIÓN DINÁMICA (ROOT)
  # =========================================================================
  authenticated :user, ->(u) { u.role == "admin" } do
    root to: "dashboards#projects", as: :admin_root
  end

  authenticated :user do
    root to: "client_portal#index", as: :client_root
  end

  unauthenticated do
    root to: "auth#login"
  end

  # =========================================================================
  # 2. AUTENTICACIÓN Y GESTIÓN DE USUARIOS
  # =========================================================================
  devise_for :users, skip: [ :registrations ], controllers: { invitations: "users/invitations" }

  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
  end

  resources :users do
    member do
      post :resend_invitation
      post :impersonate
    end
    collection do
      post :stop_impersonating
    end
  end

  # =========================================================================
  # 3. DASHBOARDS Y PORTAL
  # =========================================================================
  resources :dashboards, only: [ :index ] do
    collection do
      get :analytics, :crm, :projects, :wallet
    end
  end

  get "portal", to: "client_portal#index", as: :client_dashboard

  # =========================================================================
  # 4. RUTAS PÚBLICAS Y GLOBALES (ADMIN SIDEBAR)
  # =========================================================================

  # Cotizaciones Públicas (Fuera de la autenticación)
  get "/cotizacion/:code", to: "public_quotations#show", as: :public_quotation
  post "/cotizacion/:code/authorize", to: "public_quotations#authorize", as: :authorize_public_quotation

  # Vistas Integrales Admin
  get "cotizaciones", to: "quotations#index", as: :all_quotations
  get "cumplimiento-legal", to: "legal_compliances#index", as: :all_legal_compliances

  # =========================================================================
  # 5. NÚCLEO: CLIENTES -> PROYECTOS -> ACTIVIDADES / FINANZAS
  # =========================================================================
  resources :clients do
    member { get "timeline" }

    # --- CHAT / CONVERSACIONES ---
    resources :conversations do
      collection do
        get :start_chat
        post :create_group
      end
      resources :messages, only: [ :index, :create, :update, :destroy ]
    end

    # --- PROYECTOS (Unificado) ---
    resources :projects do
      # 5.1 Acciones del Proyecto
      member do
        post :add_comment
        get :comments, :schedule_view
        delete :delete_file
      end

      # 5.2 Módulos Legales y Cotizaciones
      resource :billing_authorization, only: [ :show, :edit, :update ] do
        post :accept, on: :member
      end

      resources :quotations, only: [ :index, :new, :create, :show, :destroy ] do
        member do
          post :send_to_client
          patch :upload_invoice
          get :preview
        end
      end

      # 5.3 Módulo Financiero
      resource :financials, only: [ :show ] do
        post :generate_template
        delete :reset_template
        post :create_payment
        patch :update_payment
        delete :destroy_payment
        patch :update_accrual
      end

      # 5.4 Operación del Proyecto
      resources :comments, controller: "project_comments", only: [ :create, :index ]
      resources :stages, except: [ :index, :show ]
      resources :project_members, only: [ :create, :destroy ]

      # 5.5 Actividades
      resources :activities, only: [ :new, :create, :edit, :update, :destroy ] do
        member do
          get :tracking
          patch :toggle
          patch :upload_evidence
          patch :update_evidence_date
          patch :update_status
          patch :toggle_user_approval
          patch :toggle_admin_approval
        end
      end
    end
  end

  # =========================================================================
  # 6. PLANTILLAS DE METODOLOGÍAS (ADMIN)
  # =========================================================================
  resources :project_templates do
    post :clone, on: :member
    resources :stage_templates, shallow: true, only: [ :create, :update, :destroy ] do
      resources :activity_templates, shallow: true, only: [ :create, :update, :destroy ]
    end
  end

  # =========================================================================
  # 7. NOTIFICACIONES Y TIMELINE
  # =========================================================================
  resources :notifications, only: [ :index, :show ] do
    member { get :mark_as_read }
  end

  patch "timeline/update_event", to: "timeline_events#update", as: :update_timeline_event

  # =========================================================================
  # 8. CUESTIONARIOS Y EVALUACIONES
  # =========================================================================
  get "diagnostico", to: "public_questionnaires#new", as: :new_diagnostico
  post "diagnostico", to: "public_questionnaires#create", as: :public_questionnaires
  get "diagnostico_exito", to: "public_questionnaires#exito", as: :success_page

  get "autodiagnostico", to: "public_questionnaires#new_autodiagnostico", as: :new_autodiagnostico
  post "autodiagnostico", to: "public_questionnaires#create_autodiagnostico", as: :create_autodiagnostico
  get "autodiagnostico_exito/:id", to: "public_questionnaires#autodiagnostico_exito", as: :autodiagnostico_exito
  get "autodiagnostico_pdf/:id", to: "public_questionnaires#download_pdf", as: :autodiagnostico_pdf

  get "/evaluacion_membresia", to: "public_questionnaires#new_membership", as: :new_membership
  get "/membresia/resultado/:id", to: "public_questionnaires#membership_result", as: :membership_result
  get "/membresia_pdf/:id", to: "public_questionnaires#download_membership_pdf", as: :membership_pdf

  get "logout-success", to: "pages#logout_success", as: :logout_success

  # =========================================================================
  # 9. ADMIN SYSTEM WORKERS
  # =========================================================================
  namespace :admin do
    resources :prospect_questionnaires, only: [ :index, :show, :update, :destroy ]
    get "system", to: "system_metrics#index"
    get "system_metrics_data", to: "system_metrics#chart_data"
    get "system_logs", to: "system_metrics#logs"
    get "system_worker_stats", to: "system_metrics#worker_stats"
    post "retry_failed_jobs", to: "system_metrics#retry_failed_jobs"
    post "discard_failed_jobs", to: "system_metrics#discard_all_failed_jobs"
  end

  # Ruta compartida para el historial legal
  get "mi-expediente-legal", to: "legal_compliances#index", as: :client_legal_history

  # =========================================================================
  # 10. RUTAS DE PLANTILLA HYPER (UI / TESTS)
  # =========================================================================
  get "apps/calendar"; get "apps/chat"; get "apps/social-feed", to: "apps#social_feed"
  get "apps/file-manager", to: "apps#file_manager"
  get "apps/email/inbox", to: "apps#email_inbox"; get "apps/email/read", to: "apps#email_read"
  get "apps/projects/add", to: "apps#projects_add"; get "apps/projects/details", to: "apps#projects_details"
  get "apps/projects/gantt", to: "apps#projects_gantt"; get "apps/projects/list", to: "apps#projects_list"
  get "apps/tasks/list", to: "apps#tasks_list"; get "apps/tasks/details", to: "apps#tasks_details"; get "apps/tasks/kanban", to: "apps#tasks_kanban"
  get "crm/management"; get "crm/orders-list", to: "crm#orders_list"; get "crm/projects"
  get "e-commerce/cart", to: "e_commerce#cart"; get "e-commerce/checkout", to: "e_commerce#checkout"
  get "e-commerce/customers", to: "e_commerce#customers"; get "e-commerce/orders", to: "e_commerce#orders"
  get "e-commerce/orders/details", to: "e_commerce#orders_details"; get "e-commerce/products", to: "e_commerce#products"
  get "e-commerce/products/details", to: "e_commerce#products_details"; get "e-commerce/sellers", to: "e_commerce#sellers"
  get "pages/faq"; get "pages/invoice"; get "pages/maintenance"; get "pages/preloader"; get "pages/pricing"; get "pages/profile"; get "pages/profile-2", to: "pages#profile_2"; get "pages/starter"; get "pages/timeline"
  get "auth/confirm-mail", to: "auth#confirm_mail"; get "auth/confirm-mail-2", to: "auth#confirm_mail_2"; get "auth/lock-screen", to: "auth#lock_screen"; get "auth/lock-screen-2", to: "auth#lock_screen_2"; get "auth/login", to: "auth#login"; get "auth/login-2", to: "auth#login_2"; get "auth/logout", to: "auth#logout"; get "auth/logout-2", to: "auth#logout_2"; get "auth/recover-password", to: "auth#recover_password"; get "auth/recover-password-2", to: "auth#recover_password_2"; get "auth/register", to: "auth#register"; get "auth/register-2", to: "auth#register_2"
  get "error/404", to: "error#error_404", as: :error_404; get "error/404-alt", to: "error#error_404_alt", as: :error_404_alt; get "error/500", to: "error#error_500", as: :error_500
  get "landing", to: "landing#index", as: :landing_index
  get "layouts/vertical", to: "layouts_eg#vertical", as: :layouts_eg_vertical; get "layouts/compact", to: "layouts_eg#compact", as: :layouts_eg_compact; get "layouts/detached", to: "layouts_eg#detached", as: :layouts_eg_detached; get "layouts/full", to: "layouts_eg#full", as: :layouts_eg_full; get "layouts/fullscreen", to: "layouts_eg#fullscreen", as: :layouts_eg_fullscreen; get "layouts/horizontal", to: "layouts_eg#horizontal", as: :layouts_eg_horizontal; get "layouts/hover", to: "layouts_eg#hover", as: :layouts_eg_hover; get "layouts/icon-view", to: "layouts_eg#icon_view", as: :layouts_eg_icon_view
  get "ui/accordions"; get "ui/alerts"; get "ui/avatars"; get "ui/badges"; get "ui/breadcrumb"; get "ui/buttons"; get "ui/cards"; get "ui/carousel"; get "ui/dropdowns"; get "ui/embed-video", to: "ui#embed_video"; get "ui/grid"; get "ui/links"; get "ui/list-group", to: "ui#list_group"; get "ui/modals"; get "ui/notifications"; get "ui/offcanvas"; get "ui/pagination"; get "ui/placeholders"; get "ui/popovers"; get "ui/progress"; get "ui/ribbons"; get "ui/spinners"; get "ui/tabs"; get "ui/tooltips"; get "ui/typography"; get "ui/utilities"
  get "extended/dragula"; get "extended/range-slider", to: "extended#range_slider"; get "extended/ratings"; get "extended/scrollbar"; get "extended/scrollspy"; get "extended/treeview"
  get "widgets", to: "widgets#index", as: :widgets_index
  get "icons/lucide"; get "icons/mdi"; get "icons/remixicons"; get "icons/unicons"
  get "charts/apex/area", to: "charts#apex_area"; get "charts/apex/bar", to: "charts#apex_bar"; get "charts/apex/boxplot", to: "charts#apex_boxplot"; get "charts/apex/bubble", to: "charts#apex_bubble"; get "charts/apex/candlestick", to: "charts#apex_candlestick"; get "charts/apex/column", to: "charts#apex_column"; get "charts/apex/heatmap", to: "charts#apex_heatmap"; get "charts/apex/line", to: "charts#apex_line"; get "charts/apex/mixed", to: "charts#apex_mixed"; get "charts/apex/pie", to: "charts#apex_pie"; get "charts/apex/polar_area", to: "charts#apex_polar_area"; get "charts/apex/radar", to: "charts#apex_radar"; get "charts/apex/radialbar", to: "charts#apex_radialbar"; get "charts/apex/scatter", to: "charts#apex_scatter"; get "charts/apex/sparklines", to: "charts#apex_sparklines"; get "charts/apex/timeline", to: "charts#apex_timeline"; get "charts/apex/treemap", to: "charts#apex_treemap"
  get "charts/chartjs/area", to: "charts#chartjs_area"; get "charts/chartjs/bar", to: "charts#chartjs_bar"; get "charts/chartjs/line", to: "charts#chartjs_line"; get "charts/chartjs/other", to: "charts#chartjs_other"; get "charts/brite"; get "charts/sparkline"
  get "forms/advanced"; get "forms/editors"; get "forms/elements"; get "forms/fileuploads"; get "forms/validation"; get "forms/wizard"
  get "tables/basic"; get "tables/datatable"; get "maps/google"; get "maps/vector"
end
