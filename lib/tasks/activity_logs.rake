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
      prunes = activity.prune_stale_evidence_logs!(dry_run: !apply)
      syncs  = activity.resync_log_dates!(dry_run: !apply)
      next if prunes.empty? && syncs.empty?

      puts "\nActividad ##{activity.id} (proyecto #{activity.stage.project_id}) — #{activity.name.to_s[0, 70]}"
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

    puts "\nResumen: eliminar=#{total[:destroy]} reescribir=#{total[:rewrite]} fechas=#{total[:fecha]}"
    puts "Nada se modificó (dry run)." unless apply
  end
end
