
module Appointments
  class NotifyStatusChangeJob < ApplicationJob
    queue_as :soon

    def perform(user, key, message)
      user.user_devices.find_each do |user_device|
        Notification.send_appointment_status_change_notification(message, key, user_device.device_id)
      end
    end
  end
end
