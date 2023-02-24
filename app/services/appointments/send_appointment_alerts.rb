module Appointments
  class SendAppointmentAlerts

    STATUSES = [
      { hours: 1.hours, field: 'is_1_hour', alert_setting: 1 },
      { hours: 12.hours, field: 'is_12_hour', alert_setting: 12 },
      { hours: 24.hours, field: 'is_14_hour', alert_setting: 24 }
    ]

    def self.run
      self.new.run
    end

    def run
      Rails.logger.info 'Send Appointment Alerts - Starting up...'

      current_time = Time.now.in_time_zone('Asia/Karachi')

      STATUSES.each do |status|
        appointments = fetch_appointments(current_time + status[:hours], status[:alert_setting])
        appointments.update_all("#{status[:field]} = true")

        Appointments::NotifyAlertsJob.perform_later(appointments)
      end
    end

    private

    def fetch_appointments(alert_time, alert_setting)
      Appointment.joins(user: :alert_setting)
                 .where('is_alert = ? AND time = ? AND date = ? AND status = ? AND is_1_hour = ?',
                        true,
                        alert_time.strftime('2000-01-01 %H:%M:00'),
                        Time.now.in_time_zone("Asia/Karachi").to_date,
                        'confirmed',
                        false
                      )
                  .where(alert_setting: { status: alert_setting })
    end
  end
end
