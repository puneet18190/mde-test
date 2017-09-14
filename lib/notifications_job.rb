require 'notification'

# +DelayedJob+ job which sends the user web notifications
class NotificationsJob < Struct.new(:user_ids, :title, :message, :basement)
  def perform
    user_ids.each{ |id| Notification.send_to(id, title, message, basement) }
  rescue => e
    ExceptionLogger.log e
    ExceptionNotifier.notify_exception e
    raise e
  end
end
