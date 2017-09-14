# Test notifications in any language
module NotificationsTest
  
  # Method that tries to send all the notifications in a given language
  def self.try_all(language, an_user_id)
    I18n.locale = language
    # 1 - documents.destroyed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.documents.destroyed.title'),
      I18n.t('notifications.documents.destroyed.message', :document_title => 'La seconda guerra mondiale', :lesson_title => 'Gelato al cioccolato'),
      I18n.t('notifications.documents.destroyed.basement', :lesson_title => 'Gelato al cioccolato', :link => 'www.google.com')
    )
    # 2 - lessons.destroyed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.lessons.destroyed.title'),
      I18n.t('notifications.lessons.destroyed.message', :user_name => 'Luciano Moggi', :lesson_title => 'Gelato al cioccolato'),
      ''
    )
    # 3 - lessons.link_sent
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.lessons.link_sent.title'),
      I18n.t('notifications.lessons.link_sent.message', :title => 'Gelato al cioccolato', :message => 'Guardate che bella lezione!', :emails => 'moggi@figc.it, carraro@figc.it'),
      ''
    )
    # 4 - lessons.modified
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.lessons.modified.title'),
      I18n.t('notifications.lessons.modified.message', :lesson_title => 'Gelato al cioccolato', :message => 'Ho aggiornato le ultime slides'),
      I18n.t('notifications.lessons.modified.basement', :lesson_title => 'Gelato al cioccolato', :link => 'www.google.com')
    )
    # 5 - lessons.unpublished
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.lessons.unpublished.title'),
      I18n.t('notifications.lessons.unpublished.message', :user_name => 'Luciano Moggi', :lesson_title => 'Gelato al cioccolato'),
      ''
    )
    # 6 - audio.compose.update.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.update.started.title'),
      I18n.t('notifications.audio.compose.update.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 7 - audio.compose.update.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.update.ok.title'),
      I18n.t('notifications.audio.compose.update.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 8 - audio.compose.update.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.update.failed.title'),
      I18n.t('notifications.audio.compose.update.failed.message', :item => 'Gelato al cioccolato', :link => 'www.google.com'),
      ''
    )
    # 9 - audio.compose.create.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.create.started.title'),
      I18n.t('notifications.audio.compose.create.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 10 - audio.compose.create.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.create.ok.title'),
      I18n.t('notifications.audio.compose.create.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 11 - audio.compose.create.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.compose.create.failed.title'),
      I18n.t('notifications.audio.compose.create.failed.message', :item => 'Gelato al cioccolato', :link => 'www.google.com'),
      ''
    )
    # 12 - audio.upload.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.upload.started.title'),
      I18n.t('notifications.audio.upload.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 13 - audio.upload.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.upload.ok.title'),
      I18n.t('notifications.audio.upload.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 14 - audio.upload.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.audio.upload.failed.title'),
      I18n.t('notifications.audio.upload.failed.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 15 - video.compose.update.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.update.started.title'),
      I18n.t('notifications.video.compose.update.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 16 - video.compose.update.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.update.ok.title'),
      I18n.t('notifications.video.compose.update.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 17 - video.compose.update.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.update.failed.title'),
      I18n.t('notifications.video.compose.update.failed.message', :item => 'Gelato al cioccolato', :link => 'www.google.com'),
      ''
    )
    # 18 - video.compose.create.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.create.started.title'),
      I18n.t('notifications.video.compose.create.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 19 - video.compose.create.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.create.ok.title'),
      I18n.t('notifications.video.compose.create.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 20 - video.compose.create.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.compose.create.failed.title'),
      I18n.t('notifications.video.compose.create.failed.message', :item => 'Gelato al cioccolato', :link => 'www.google.com'),
      ''
    )
    # 21 - video.upload.started
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.upload.started.title'),
      I18n.t('notifications.video.upload.started.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 22 - video.upload.ok
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.upload.ok.title'),
      I18n.t('notifications.video.upload.ok.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 23 - video.upload.failed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.video.upload.failed.title'),
      I18n.t('notifications.video.upload.failed.message', :item => 'Gelato al cioccolato'),
      ''
    )
    # 24 - account.renewed
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.account.renewed.title'),
      I18n.t('notifications.account.renewed.message', :expiration_date => '1 gennaio 2014'),
      ''
    )
    # 25 - account.trial
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.account.trial.title', :user_name => 'Luciano Moggi'),
      I18n.t('notifications.account.trial.message', :desy => 'DESY', :validity => '30'),
      I18n.t('notifications.account.trial.basement', :desy => 'DESY', :link => 'www.google.com')
    )
    # 26 - account.upgraded
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.account.upgraded.title'),
      I18n.t('notifications.account.upgraded.message', :expiration_date => '1 gennaio 2014'),
      ''
    )
    # 27 - account.welcome
    Notification.send_to(
      an_user_id,
      I18n.t('notifications.account.welcome.title', :user_name => 'Luciano Moggi'),
      I18n.t('notifications.account.welcome.message', :desy => 'DESY', :expiration_date => '1 gennaio 2014'),
      ''
    )
    # Here I set the times to be all different
    time = Time.zone.now
    decrement = 0
    Notification.order('id DESC').each do |n|
      Notification.where(:id => n.id).update_all(:created_at => time + decrement)
      decrement += 1
    end
  end
  
end
