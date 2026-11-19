# frozen_string_literal: true

require 'csv'
require 'json'
require 'fileutils'

INPUT_PATH  = File.join(__dir__, 'data', 'contacts.csv')
OUTPUT_DIR  = File.join(__dir__, 'output')
VALID_PATH  = File.join(OUTPUT_DIR, 'contacts.json')
ERRORS_PATH = File.join(OUTPUT_DIR, 'errors.csv')

EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

# Перевіряє один рядок CSV і повертає масив причин помилок
def validate_row(name, email)
    reasons = []
    reasons << "порожнє ім'я" if name.empty?
    reasons << 'некоректний email' unless email.match?(EMAIL_REGEX)
    reasons
end

# Читає вхідний CSV та розподіляє записи на коректні й помилкові
def process_contacts(file_path)
    valid = []
    errors = []

    CSV.foreach(file_path, headers: true) do |row|
        name  = row['name'].to_s.strip
        email = row['email'].to_s.strip.downcase

        reasons = validate_row(name, email)

        if reasons.empty?
            valid << { 'name' => name, 'email' => email }
        else
            raw_row = row.fields.map { |field| field.to_s.strip }.join(',')
            errors << [raw_row, reasons.join('; ')]
        end
    end

    [valid, errors]
end

# Зберігає валідні контакти у JSON та помилки у CSV
def save_results(valid, errors)
    FileUtils.mkdir_p(OUTPUT_DIR)

    File.write(VALID_PATH, "#{JSON.pretty_generate(valid)}\n")

    CSV.open(ERRORS_PATH, 'w') do |csv|
        csv << %w[row reason]
        errors.each { |error_row| csv << error_row }
    end
end

unless File.exist?(INPUT_PATH)
    warn "Помилка: вхідний файл не знайдено (#{INPUT_PATH})"
    exit 1
end

valid_contacts, error_rows = process_contacts(INPUT_PATH)
save_results(valid_contacts, error_rows)

puts "Коректних: #{valid_contacts.size}, з помилками: #{error_rows.size}"