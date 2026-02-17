class AppsController < ApplicationController
  def calendar
  end

  def chat
  end

  def social_feed
  end

  def file_manager
  end

  def email_inbox
    render template: "apps/email/inbox"
  end

  def email_read
    render template: "apps/email/read"
  end

  def projects_add
    render template: "apps/projects/add"
  end

  def projects_details
    render template: "apps/projects/details"
  end

  def projects_gantt
    render template: "apps/projects/gantt"
  end

  def projects_list
    render template: "apps/projects/list"
  end

  def tasks_list
    render template: "apps/tasks/list"
  end

  def tasks_details
    render template: "apps/tasks/details"
  end

  def tasks_kanban
    render template: "apps/tasks/kanban"
  end
end
