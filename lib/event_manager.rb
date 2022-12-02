require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.tr('^0-9', '')
  if phone_number.length < 10 || phone_number.length > 11
    '0000000000'
  elsif phone_number.length == 11 && phone_number[0] != '1'
    '0000000000'
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number[1..10]
  else
    phone_number
  end
end

def array_freq(array)
  result = Hash.new(0)
  array.each { |key| result[key] += 1 }
  result
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hours = Array.new(0)
weekdays = Array.new(0)

contents.each_with_index do |row, index|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  phone_number = clean_phone_number(row[:homephone])
  # puts phone_number

  reg_date = row[:regdate]
  hours[index] = Time.strptime(reg_date, '%m/%d/%Y %k:%M').hour
  weekdays[index] = Time.strptime(reg_date, '%m/%d/%Y %k:%M').wday
  # puts hours

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

puts "\n # People registered at the following hours:
hour => frequency \n"
puts array_freq(hours)

puts "\n # People registered at the following weekday:
weekday => frequency
0: Sunday, 1: Monday, 2: Tuesday, 3: Wednesday, 4: thursday, 5: Friday, 6: Saturday \n"
puts array_freq(weekdays)
