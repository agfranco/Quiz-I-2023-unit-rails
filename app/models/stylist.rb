class Stylist < ApplicationRecord

  def full_title
    translations.first.title + ' ' + translations.first.name
  end
end
