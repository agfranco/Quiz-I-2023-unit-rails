module Appointments
  class AlertStatusChange
    attr_reader :appointment

    delegate :user, to: :appointment

    def initialize(appointment)
      @appointment = appointment
    end

    def self.call
      self.new(appointment).alert!
    end

    private

    def alert!
      return if user.blank?
      return unless appointment.private?

      Appointments::NotifyStatusChangeJob.perform_later(user, key, notification_message)

      appointment.update(status_changed_at: Time.now) unless appointment.pending?
    end

    def notification_message
      message = I18n.t(translation_key, locale: 'ur')
                    .gsub('stylist', "#{translation.title.present? ? translation.title + ' ' : nil}
                                       #{translation.name}")

      if appointment.date.present? && appointment.time.present?
        message.gsub('dd', appointment.date.strftime('%d-%m-%Y'))
               .gsub('tt', appointment.time.strftime('%l:%M %p'))
      else
        message.gsub('dd', '').gsub('tt', '')
      end
    end

    def translation_key
      {
        'confirmed' => 'confirm',
        'canceled' => 'cancel',
        'rescheduled' => 'reschedule'
      }.fetch(appointment.status, appointment.status)
    end

    def translation
      @translation ||= appointment.stylist.translations.last
    end

    def key
      if appointment.confirmed? && appointment.offer_id.present?
        appointment.offer_id
      else
        1
      end
    end
  end
end
