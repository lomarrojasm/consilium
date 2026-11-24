namespace :activity_logs do
  desc "Revisa/repara historial de actividades: quita registros de evidencia ya inexistentes y alinea fechas. " \
       "Por defecto es DRY RUN (no modifica nada). Aplicar con APPLY=1. Limitar a un proyecto con PROJECT_ID=n"
  task repair: :environment do
    apply = ENV["APPLY"] == "1"
    scope = Activity.all
    scope = scope.joins(:stage).where(stages: { project_id: ENV["PROJECT_ID"] }) if ENV["PROJECT_ID"].present?

    puts apply ? "== APLICANDO CAMBIOS ==" : "== DRY RUN (no se modifica nada; usa APPLY=1 para aplicar) =="
    total = Hash.new(0)

    scope.find_each do |activity|
      evidence_fix = activity.normalize_evidence_date!(dry_run: !apply)   # fecha de evidencia fuera de rango
      prunes = activity.prune_stale_evidence_logs!(dry_run: !apply)
      syncs  = activity.resync_log_dates!(dry_run: !apply)
      next if evidence_fix.nil? && prunes.empty? && syncs.empty?

      puts "\nActividad ##{activity.id} (proyecto #{activity.stage.project_id}) — #{activity.name.to_s[0, 70]}"
      if evidence_fix
        total[:evidencia] += 1
        puts "  - FECHA EVIDENCIA fuera de rango (actividad creada #{activity.created_at.to_date}): #{evidence_fix[:from].to_date} => #{evidence_fix[:to]}"
      end
      prunes.each do |c|
        total[c[:action]] += 1
        puts c[:action] == :destroy ? "  - ELIMINAR registro ##{c[:log_id]}: #{c[:from][0, 90]}" :
                                      "  - REESCRIBIR registro ##{c[:log_id]}: #{c[:from][0, 60]} => #{c[:to][0, 60]}"
      end
      syncs.each do |c|
        total[:fecha] += 1
        puts "  - FECHA (#{c[:label]}) registro ##{c[:log_id]}: #{c[:from].to_date} => #{c[:to].to_date}"
      end
    end

    puts "\nResumen: eliminar=#{total[:destroy]} reescribir=#{total[:rewrite]} fechas=#{total[:fecha]} evidencias_fuera_de_rango=#{total[:evidencia]}"
    puts "Nada se modificó (dry run)." unless apply
  end

  desc "Limpia conversaciones de actividades. Por defecto DRY RUN; aplicar con APPLY=1. " \
       "Alcance: PROJECT_ID=n (obligatorio), opcional STAGE_ID=n. MODE=conversation|files|full (por defecto conversation). " \
       "MODE=full borra también el historial de evidencia y aprobaciones."
  task clear: :environment do
    apply = ENV["APPLY"] == "1"
    mode = ENV.fetch("MODE", "conversation")
    abort "MODE inválido (#{Activity::CLEAR_MODES.join(' | ')})" unless Activity::CLEAR_MODES.include?(mode)
    abort "Indica PROJECT_ID=n" if ENV["PROJECT_ID"].blank?

    project = Project.find(ENV["PROJECT_ID"])
    activities = ENV["STAGE_ID"].present? ? project.stages.find(ENV["STAGE_ID"]).activities : project.activities

    puts apply ? "== APLICANDO (modo #{mode}) ==" : "== DRY RUN (modo #{mode}; usa APPLY=1 para aplicar) =="
    total = 0
    ActivityLog.transaction do
      activities.find_each do |activity|
        logs = activity.clearable_logs(mode)
        next if logs.empty?
        total += logs.size
        puts "Actividad ##{activity.id} (#{activity.name.to_s[0, 60]}): #{logs.size} registro(s)"
        logs.each(&:destroy!) if apply
      end
    end
    puts "\nTotal: #{total} registro(s) #{apply ? 'eliminados' : 'que se eliminarían'}."
  end
end
