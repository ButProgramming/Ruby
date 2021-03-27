require 'csv'
CSV.open("myfile.csv", "w") do |csv|
  csv << ["row", "of", "CSV", "data"]
  csv << ["another", "row"]
end


p = Array.new
person = {
    name: "123",
    surname: "12345"
}

p << person

puts p[0][:name]