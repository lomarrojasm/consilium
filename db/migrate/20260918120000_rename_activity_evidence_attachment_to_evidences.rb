class RenameActivityEvidenceAttachmentToEvidences < ActiveRecord::Migration[8.0]
  # Activity pasa de has_one_attached :evidence a has_many_attached :evidences.
  # Solo renombramos el "name" de los adjuntos existentes: los blobs (archivos) no se tocan.
  def up
    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET name = 'evidences'
      WHERE record_type = 'Activity' AND name = 'evidence'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET name = 'evidence'
      WHERE record_type = 'Activity' AND name = 'evidences'
    SQL
  end
end
