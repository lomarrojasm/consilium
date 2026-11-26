require "test_helper"

class ActivityEvidencesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Este test arma sus propios datos; los fixtures globales del repo son stubs vacíos.
  self.fixture_table_names = []

  setup do
    @client  = Client.create!(company_name: "Evidencias SA", rfc: "EVI010101AAA")
    @admin  = User.create!(email: "ev-admin@example.com", password: "password123", first_name: "Ada", last_name: "Admin", role: :admin)
    @lider  = User.create!(email: "ev-lider@example.com", password: "password123", first_name: "Leo", last_name: "Lider", role: :user, client: @client)
    @analyst = User.create!(email: "ev-analyst@example.com", password: "password123", first_name: "Ana", last_name: "Analista", role: :user, client: @client)

    @project = Project.create!(client: @client, user: @admin, name: "Proyecto Evidencias", start_date: Date.current)
    ProjectMember.create!(project: @project, user: @lider, role: "lider")
    ProjectMember.create!(project: @project, user: @analyst, role: "analista")

    @stage = Stage.create!(project: @project, name: "Etapa 1")
    @activity = Activity.create!(stage: @stage, user: @admin, name: "Actividad A", created_at: Time.zone.local(2026, 6, 14, 9))
    # Segunda actividad pendiente para que la etapa no quede al 100% (y bloqueada) al subir evidencia
    @other = Activity.create!(stage: @stage, user: @admin, name: "Actividad B")
  end

  def pdf(name = "a.pdf")
    Rack::Test::UploadedFile.new(StringIO.new("%PDF-1.4 #{name}"), "application/pdf", original_filename: name)
  end

  def upload(*files, date: "2026-06-15")
    patch upload_evidence_client_project_activity_path(@client, @project, @activity),
          params: { activity: { evidence_date: date, evidences: files } }
  end

  def destroy_evidence(attachment)
    delete destroy_evidence_client_project_activity_path(@client, @project, @activity, attachment_id: attachment.id)
  end

  test "sube varios archivos de una vez y registra un solo log" do
    sign_in @admin
    assert_difference -> { @activity.activity_logs.count }, 1 do
      upload pdf("uno.pdf"), pdf("dos.pdf")
    end

    @activity.reload
    assert_equal %w[dos.pdf uno.pdf], @activity.evidences.map { |e| e.filename.to_s }.sort
    assert @activity.completed
    assert_equal Date.new(2026, 6, 15), @activity.evidence_uploaded_at.to_date
    assert_includes @activity.activity_logs.last.comment, "2 archivos"
  end

  test "una segunda carga suma archivos y no cambia la fecha oficial" do
    sign_in @admin
    upload pdf("uno.pdf")
    upload pdf("dos.pdf"), date: "2026-07-20"

    @activity.reload
    assert_equal 2, @activity.evidences.count
    assert_equal Date.new(2026, 6, 15), @activity.evidence_uploaded_at.to_date
  end

  test "sin archivos o con fecha invalida no carga nada" do
    sign_in @admin
    upload date: "2026-06-15"
    assert_equal 0, @activity.reload.evidences.count
    assert_match "Debes adjuntar", flash[:alert]

    upload pdf, date: "no-es-fecha"
    assert_equal 0, @activity.reload.evidences.count
    assert_match "Debes adjuntar", flash[:alert]
  end

  test "un lider elimina una evidencia y queda registro en el historial" do
    sign_in @admin
    upload pdf("uno.pdf"), pdf("dos.pdf")

    sign_in @lider
    target = @activity.reload.evidences_attachments.detect { |a| a.filename.to_s == "uno.pdf" }
    key = target.blob.key
    assert_difference -> { ActiveStorage::Attachment.count }, -1 do
      destroy_evidence target
    end

    assert_equal [ "dos.pdf" ], @activity.reload.evidences.map { |e| e.filename.to_s }
    assert_not ActiveStorage::Blob.exists?(target.blob_id)
    assert_not ActiveStorage::Blob.service.exist?(key)
    assert_match "🗑️ Eliminó la evidencia: uno.pdf", @activity.activity_logs.order(:id).last.comment
    assert_match "Evidencia eliminada", flash[:notice]
  end

  test "un analista no puede eliminar evidencias" do
    sign_in @admin
    upload pdf("uno.pdf")

    sign_in @analyst
    assert_no_difference -> { ActiveStorage::Attachment.count } do
      destroy_evidence @activity.reload.evidences_attachments.first
    end
    assert_match "Solo un administrador", flash[:alert]
  end

  test "no se puede eliminar evidencia de una actividad finalizada" do
    sign_in @admin
    upload pdf("uno.pdf")
    @activity.update!(admin_approved: true, user_approved: true)

    assert_no_difference -> { ActiveStorage::Attachment.count } do
      destroy_evidence @activity.reload.evidences_attachments.first
    end
    assert_match "finalizada", flash[:alert]
  end

  test "no se puede eliminar un adjunto de otra actividad" do
    sign_in @admin
    upload pdf("uno.pdf")
    other_activity = @other
    other_activity.evidences.attach(pdf("ajeno.pdf"))
    foreign = other_activity.evidences_attachments.first

    assert_no_difference -> { ActiveStorage::Attachment.count } do
      destroy_evidence foreign # ruta de @activity con el id de un adjunto de @other
    end
    assert_equal 1, other_activity.reload.evidences.count
    assert_match "ya no existe", flash[:alert]
  end

  test "la tabla del proyecto muestra la lista de evidencias y el boton de borrar" do
    sign_in @admin
    upload pdf("uno.pdf"), pdf("dos.pdf")

    get client_project_path(@client, @project)
    assert_response :success
    assert_select "#activity-row-#{@activity.id} .dropdown-menu .dropdown-item", text: /uno\.pdf/
    assert_select "#activity-row-#{@activity.id} .dropdown-menu .dropdown-item", text: /dos\.pdf/
    assert_select "#activity-row-#{@activity.id} button[data-url*='destroy_evidence']", 2
    assert_select "#activity-row-#{@activity.id} .badge", text: "2"
  end

  test "un analista ve la lista pero sin boton de borrar" do
    sign_in @admin
    upload pdf("uno.pdf"), pdf("dos.pdf")

    sign_in @analyst
    get client_project_path(@client, @project)
    assert_response :success
    assert_select "#activity-row-#{@activity.id} .dropdown-menu .dropdown-item", text: /uno\.pdf/
    assert_select "#activity-row-#{@activity.id} button[data-url*='destroy_evidence']", 0
  end

  test "el modal de seguimiento indica cuantos archivos hay cargados" do
    sign_in @admin
    upload pdf("uno.pdf"), pdf("dos.pdf")

    get tracking_client_project_activity_path(@client, @project, @activity)
    assert_response :success
    assert_match "Cargada (2 archivos)", response.body
  end

  test "el timeline del cliente lista todos los archivos de la actividad" do
    sign_in @admin
    upload pdf("uno.pdf"), pdf("dos.pdf")
    TimelineLog.create!(client: @client, user: @admin, resource: @activity, action_type: "update", details: "✅ Tarea completada")

    get timeline_client_path(@client)
    assert_response :success
    assert_match "uno.pdf", response.body
    assert_match "dos.pdf", response.body
  end

  test "al completar la actividad el timeline registra los nombres de todos los archivos" do
    sign_in @admin
    travel 1.minute # la actividad no debe verse como recien creada para que se registre el cambio
    upload pdf("uno.pdf"), pdf("dos.pdf")

    log = TimelineLog.where(resource: @activity).order(:id).last
    assert log, "debe existir un log de timeline"
    assert_match "uno.pdf", log.details
    assert_match "dos.pdf", log.details
  end
end
