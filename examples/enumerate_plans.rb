require "nurego"

Nurego.api_base = "https://api.nurego.com"
Nurego.api_key = "YOUR INSTANCE KEY"   #login to nurego.com and check Settings/Organization for api keys

begin
  offering = Nurego::Offering.current
  offering.plans.each do |plan|
    puts plan.inspect
    plan.features.each do |feature|
      puts feature.inspect
    end
  end
rescue Nurego::NuregoError => e
  puts "ERROR #{e.error_code}"
end

