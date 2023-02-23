module Barcodable
  extend ActiveSupport::Concern

  def generate_barcode
    dir = File.dirname(Rails.root.join('/path_to_folder/create.log'))
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    barcode = Barby::Code128B.new("#{self.class.name.downcase}#{self.id}")
    blob = Barby::PngOutputter.new(barcode).to_png # Raw PNG data
    File.open(Rails.root.join("/path_to_folder/#{self.id}.png"), 'wb') {|f| f.write blob }
  end

  def get_barcode
    barcode = Rails.root.join(
      "public/barcodes/#{self.class.name.downcase.pluralize}/a#{self.id}.png"
    )
    barcode_out = "/path_to_folder/#{self.id}.png"

    generate_barcode unless File.exists? barcode

    barcode_out
  end
end
