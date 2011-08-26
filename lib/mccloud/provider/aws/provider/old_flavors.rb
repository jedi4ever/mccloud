module Mccloud
  module Command
    def flavors()  
      puts ""
      puts "Available flavors"
      provider=@provider.config.providers.first[1]
      flavors=provider.flavors
      formatting="%-12s %-35s %-6s %-6s %-6s %-6s\n"
      printf formatting,"id","name","bits","cores","disk", "ram"
      80.times { |i| printf "=" } ; puts

      flavors.each  do |flavor|
        printf formatting,flavor.id,flavor.name[0..34],flavor.bits,flavor.cores,flavor.disk, flavor.ram
      end

    end #def
  end #module
end
