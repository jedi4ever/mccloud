require 'erb'
module Mccloud
  class Mccloudfile

    attr_accessor :path
    attr_accessor :sections
    attr_accessor :name

    def initialize(path)
      # Path to the file
      @path=path

      # Tags to be enable for the comment
      @sections=[:aws]

      # Name to use as the base machine
      @name="mccloud"
    end

    def exists?
      return File.exists?(@path)
    end

    # Bindings in ERB http://www.stuartellis.eu/articles/erb/
    # Links:
    # * Trimming whitespace in ERB
    # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/242656
    # * Appending to ERB output
    # http://blog.jayfields.com/2007/01/appending-to-erb-output-from-block.html
    def uncomment(selection)

      cur_pos=@output.length
      yield
      new_pos=@output.length

      if exclude_section?(selection)
        # Extract the block
        block_text=@output[cur_pos..new_pos]

        # Remove the block
        @output[cur_pos..new_pos]=''

        # Comment the block, with leading spaces into account
        block_text.gsub!(/^(\s)*/,'\1# ')

        # Re-insert the block
        @output=@output.insert cur_pos, block_text
      end
    end

    def exclude_section?(section)
      section.each do |s|
        return false if @sections.include?(s)
      end
      return true
    end

    def save
    end

    def to_s
      template=File.new(File.join(File.dirname(__FILE__),"templates","Mccloudfile.erb")).read
      result=::ERB.new(template,nil,"-","@output").result(binding)
      return result
    end

  end
end
