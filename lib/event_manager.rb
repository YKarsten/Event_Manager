require 'csv'

def clean_zipcode(zipcode)
  # if zipcode.nil?
  #   '00000'
  # elsif zipcode.length < 5
  #   zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode[0..4]
  # else
  #   zipcode
  # end
zipcode.to_s.rjust(5, '0')[0..4]
# #.to_s converts nil to "", #.rjust only adds "0" if string if the length < 5, otherwise it does nothing. slice[0..4] doesnt do anything to numbers with exactly 5 digits in length. This way all the methods can be applied to the zipcode and simplyfiy the above if else structure.
end

puts 'Event Manager initialized!'

contents = CSV.open(
  'event_attendees.csv',
   headers: true,
   header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  
  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} at #{zipcode}"
end
