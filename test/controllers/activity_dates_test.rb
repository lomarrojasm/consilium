require "test_helper"

# Regla: actividad <= conversación <= evidencia <= aprobación cliente <= Visto Bueno, en un máximo de 10 días
class ActivityDatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  self.fixture_table_names = []

  START = Date.new(2021, 3, 9)
  WINDOW = START..(START + 10)

  setup do
    @client  = Client.create!(company_name: "Fechas SA", rfc: "FEC010101AAA")
    @admin   = User.create!(email: "fe-admin@example.com", password: "password123", first_name: "Ada", last_name: "Admin", role: :admin)
    @project = Project.create!(client: @client, user: @admin, name: "Proyecto Fechas", start_date: START)
    @stage   = Stage.create!(project: @project, name: "Etapa 1")
    @activity = Activity.create!(stage: @stage, user: @admin, name: "Actividad A", created_at: START.in_time_zone.change(hour: 9))
    Activity.create!(stage: @stage, user: @admin, name: "Actividad B")
    @accrual = @project.financial_accruals.create!(stage_name: "Etapa 1", concept_name: "Actividad A", amount: 100)
    sign_in @admin
  end

  def path(action, **extra) = send("#{action}_client_project_activity_path", @client, @project, @activity, **extra)
  def json = { "Accept" => "application/json" }
  def day(value) = value.to_date
  def log_days = @activity.activity_logs.reload.order(:created_at, :id).map { |l| day(l.created_at) }

  def upload(date)
    file = Rack::Test::UploadedFile.new(StringIO.new("%PDF-1.4"), "application/pdf", original_filename: "e.pdf")
    patch path(:upload_evidence), params: { activity: { evidence_date: date.to_s, evidences: [ file ] } }, headers: json
  end

  def approve(kind, **params) = patch(path("toggle_#{kind}_approval"), params: params, headers: json)

  def assert_all_in_window
    assert log_days.all? { |d| WINDOW.cover?(d) }, "historial fuera de ventana: #{log_days}"
    TimelineLog.where(resource: @activity).each { |e| assert WINDOW.cover?(day(e.happened_at)), "timeline: #{e.details} #{e.happened_at}" }
  end

  test "evidencia y aprobaciones en un clic usan fechas de la actividad y en orden" do
    travel 1.minute
    upload(START + 2)
    approve(:user)
    approve(:admin)
    @activity.reload

    assert_equal START + 2, day(@activity.evidence_uploaded_at)
    assert_equal START + 2, day(@activity.evidences_attachments.first.created_at)
    assert_equal START + 3, day(@activity.user_approved_at)
    assert_equal START + 4, day(@activity.admin_approved_at)
    assert_equal START + 4, @accrual.reload.accrued_date
    assert_all_in_window
  end

  test "revocar y eliminar evidencia no registran la fecha de hoy" do
    upload(START + 2)
    approve(:user)
    approve(:user) # revoca
    delete path(:destroy_evidence, attachment_id: @activity.evidences_attachments.first.id), headers: json
    assert_response :success
    assert_all_in_window
    assert_equal log_days.sort, log_days
  end

  test "la aprobacion en bloque sigue la regla" do
    patch bulk_approve_client_project_activities_path(@client, @project), params: { kind: "user", ids: [ @activity.id ] }, headers: json
    patch bulk_approve_client_project_activities_path(@client, @project), params: { kind: "admin", ids: [ @activity.id ] }, headers: json
    @activity.reload
    assert_equal [ START + 1, START + 2 ], [ day(@activity.user_approved_at), day(@activity.admin_approved_at) ]
    assert_all_in_window
  end

  test "fecha manual fuera de ventana o de orden se ajusta y avisa" do
    upload(START + 4)
    approve(:user, days_after: 1)
    assert_match "ajustada", response.parsed_body["message"]
    assert_equal START + 4, day(@activity.reload.user_approved_at)

    approve(:admin, days_after: 50)
    assert_equal START + 10, day(@activity.reload.admin_approved_at)
    assert_equal START + 10, @accrual.reload.accrued_date
  end

  test "cambiar fecha de aprobacion respeta el orden y actualiza el devengo" do
    upload(START + 2)
    approve(:user)
    approve(:admin)
    patch path(:update_approval_date), params: { kind: "admin", days_after: 8 }, headers: json
    assert_equal START + 8, @accrual.reload.accrued_date

    patch path(:update_approval_date), params: { kind: "admin", days_after: 0 }, headers: json
    assert_equal day(@activity.reload.user_approved_at), day(@activity.admin_approved_at)

    patch path(:update_approval_date), params: { kind: "user", days_after: 10 }, headers: json
    assert_equal day(@activity.reload.admin_approved_at), day(@activity.user_approved_at)
    assert_all_in_window
  end

  test "un devengo capturado a mano se respeta" do
    upload(START + 2)
    approve(:user)
    approve(:admin)
    @accrual.update_columns(accrued_date: Date.new(2024, 1, 15))
    patch path(:update_approval_date), params: { kind: "admin", days_after: 9 }, headers: json
    @activity.reload.update!(name: "Actividad A")
    assert_equal Date.new(2024, 1, 15), @accrual.reload.accrued_date
  end

  test "seguimientos nunca quedan antes del ultimo registro ni fuera de la ventana" do
    patch path(:update_status), params: { status: "pending", comment: "uno", days_after: 5 }, headers: json
    patch path(:update_status), params: { status: "pending", comment: "dos", days_after: 1 }, headers: json
    patch path(:update_status), params: { status: "completed", comment: "tres", days_after: "" }, headers: json
    assert_equal [ START + 5 ] * 3, log_days
    assert_equal %w[uno dos tres], @activity.activity_logs.order(:created_at, :id).map(&:comment)
    assert_equal START + 5, day(@activity.reload.evidence_uploaded_at)
    assert_all_in_window
  end

  test "editar la fecha de la actividad desplaza todo; guardar sin cambiarla no mueve nada" do
    upload(START + 2)
    approve(:user)
    approve(:admin)
    before = @activity.activity_logs.reload.order(:id).map(&:created_at)

    patch client_project_activity_path(@client, @project, @activity), params: { activity: { name: "Actividad A", created_at: START.to_s } }
    assert_equal before, @activity.activity_logs.reload.order(:id).map(&:created_at)

    patch client_project_activity_path(@client, @project, @activity), params: { activity: { name: "Actividad A", created_at: (START - 400).to_s } }
    @activity.reload
    base = START - 400
    assert_equal base, day(@activity.created_at)
    assert_equal [ base + 2, base + 3, base + 4 ], [ @activity.evidence_uploaded_at, @activity.user_approved_at, @activity.admin_approved_at ].map { |t| day(t) }
    assert_equal [ base + 2, base + 3, base + 4 ], log_days
    assert_equal base + 4, @accrual.reload.accrued_date
  end

  test "editar la fecha de evidencia empuja las aprobaciones" do
    upload(START + 2)
    approve(:user)
    approve(:admin)
    patch path(:update_evidence_date), params: { evidence_uploaded_at: (START + 7).to_s }
    @activity.reload
    assert_equal START + 7, day(@activity.evidence_uploaded_at)
    assert_equal START + 7, day(@activity.evidences_attachments.first.created_at)
    assert day(@activity.user_approved_at) >= START + 7
    assert day(@activity.admin_approved_at) >= day(@activity.user_approved_at)
    assert_equal day(@activity.admin_approved_at), @accrual.reload.accrued_date
    assert_all_in_window
  end

  test "la reparacion corrige datos antiguos y en simulacion no cambia nada" do
    upload(START + 2)
    approve(:user)
    approve(:admin)
    today = Time.current
    @activity.update_columns(evidence_uploaded_at: today, user_approved_at: today, admin_approved_at: today)
    @activity.activity_logs.update_all(created_at: today)
    @activity.evidences_attachments.update_all(created_at: today)
    TimelineLog.where(resource: @activity).update_all(happened_at: today)
    @accrual.update_columns(accrued_date: today.to_date)

    Activity.transaction(requires_new: true) { assert @activity.normalize_dates!.any?; raise ActiveRecord::Rollback }
    assert_equal today.to_date, day(@activity.reload.admin_approved_at)

    @activity.normalize_dates!
    @activity.reload
    dates = [ @activity.evidence_uploaded_at, @activity.user_approved_at, @activity.admin_approved_at ].map { |t| day(t) }
    assert dates.all? { |d| WINDOW.cover?(d) }, dates.inspect
    assert_equal dates.sort, dates
    assert_equal dates.last, @accrual.reload.accrued_date
    assert_all_in_window
    assert_empty @activity.normalize_dates!, "una segunda pasada no debe cambiar nada"
  end

  test "la limpieza semanal no borra historial" do
    upload(START + 2)
    assert_no_difference [ -> { ActivityLog.count }, -> { TimelineLog.count } ] do
      DatabaseCleanupJob.perform_now
    end
  end
end
