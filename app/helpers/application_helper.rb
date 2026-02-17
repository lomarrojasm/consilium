module ApplicationHelper
  # ... otros helpers ...

  def can_edit_project?(project)
    return false unless current_user
    current_user.role == 'admin' || project.project_members.exists?(user: current_user)
  end

  def file_icon_class(filename)
    extension = filename.to_s.split('.').last.downcase
    
    case extension
    when 'pdf'
      'mdi-file-pdf-box text-danger'
    when 'doc', 'docx'
      'mdi-file-word-box text-primary'
    when 'xls', 'xlsx', 'csv'
      'mdi-file-excel-box text-success'
    when 'ppt', 'pptx'
      'mdi-file-powerpoint-box text-warning'
    when 'jpg', 'jpeg', 'png', 'gif', 'webp'
      'mdi-file-image text-info'
    when 'zip', 'rar', '7z'
      'mdi-zip-box text-secondary'
    when 'txt'
      'mdi-file-document-outline text-muted'
    else
      'mdi-file-outline text-dark' # Ícono por defecto
    end
  end
  
end