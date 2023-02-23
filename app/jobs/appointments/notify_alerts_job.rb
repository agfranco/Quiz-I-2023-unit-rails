
module Appointments
  class NotifyAlertsJob < ApplicationJob
    queue_as :soon

    def perform(appointments)
      appointments.find_each do |appointment|
        send_alert(appointment)
      end
    end

      private

      def send_alert(appointment)
        user.user_devices.find_each do |user_device|
          key = appointment.offer_id.present? ? appointment.offer_id : 1

          Notification.send_appointment_alerts(
            appointment_msg(appointment), key, user_device.device_id
          )
        end
      end

      def appointment_msg(appointment)
        msg = "You have an appointment with  #{appointment.stylist.full_title}"
        if appointment.date.present? and appointment.time.present?
          msg = msg + " at #{appointment.time.strftime("%H:%M")} on #{appointment.date}"
        end
        msg
      end
  end
end
