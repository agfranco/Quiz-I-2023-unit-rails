class Appointment < ApplicationRecord
  enum status: %i[pending confirmed canceled rescheduled]
  enum call_status: %i[not_called no_answer called]

  belongs_to :offer
  belongs_to :stylist
  belongs_to :user

  validates :user_id, presence: true
  validates :offer_id, presence: true
  validates_uniqueness_of :time, scope: [:offer_id, :date],
                          conditions: -> { where.not(status: %i[canceled rescheduled]) },
                          if: -> { date.present? && time.present? }

  before_validation :appointment_date_time, if: -> { date_time.present? }
  before_create { not_called! }
  after_create { Appointments::AlertStatusChange.(appointment: self) if pending? && date.present? }
  before_update { Appointments::AlertStatusChange.(appointment: self) if status_changed? }
  after_create :generate_barcode
  before_update { self.allow_refund = true if cancelled_by_admin? }

  def appointment_date_time
    self.date = date_time.to_date
    self.time = date_time.to_time.strftime('%H:%M')
  end

  def toggle_call_status
    case call_status
    when :not_called
      called!
    when :called
      no_answer!
    else
      not_called!
    end
  end

  def self.appointment_alerts
    Appointments::SendAppointmentAlerts.run # This could run as a scheduled task
  end
end
