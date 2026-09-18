module ActivitiesHelper
  # Devuelve [clase_de_icono, clase_de_color] según el tipo de archivo de la evidencia
  def evidence_file_icon(blob)
    case blob.content_type.to_s
    when "application/pdf"                        then [ "ri-file-pdf-2-line", "text-danger" ]
    when /spreadsheet|excel|csv/                  then [ "ri-file-excel-2-line", "text-success" ]
    when /wordprocessing|msword/                  then [ "ri-file-word-2-line", "text-primary" ]
    when /presentation|powerpoint/                then [ "ri-file-ppt-2-line", "text-warning" ]
    when /\Aimage\//                              then [ "ri-image-2-line", "text-info" ]
    when /zip|compressed|rar/                     then [ "ri-file-zip-line", "text-secondary" ]
    else                                               [ "ri-file-line", "text-muted" ]
    end
  end
end
