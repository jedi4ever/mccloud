module Mccloud
  class Template
    attr_accessor :file
    attr_accessor :erb
    attr_accessor :params
    attr_accessor :author
    attr_accessor :bootstrap

    attr_accessor :name
    attr_accessor :env

    def initialize(name,env)
      @name=name
      @env=env

      @erb=true
      @file=nil
      @params=Hash.new
      @author="No author specified"
      @bootstrap=nil
    end

    # Bindings in ERB http://www.stuartellis.eu/articles/erb/
    # Links:
    # * Trimming whitespace in ERB
    # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/242656
    # * Appending to ERB output
    # http://blog.jayfields.com/2007/01/appending-to-erb-output-from-block.html
    def comment(flag)
      cur_pos=@output.length
      yield
      new_pos=@output.length
      if flag

        # Extraxt the block
        block_text=@output[cur_pos..new_pos]

        # Remove the block
        @output[cur_pos..new_pos]=''

        # Comment the block, with leading spaces into account
        block_text.gsub!(/^(\s)*/,'\1# ')

        # Re-insert the block
        @output=@output.insert cur_pos, block_text
      end

    end

    def to_s
      "Template #{name}"
    end

    def to_template(vm_name="noname")
      result=""
      filename=@file
      env.logger.info "Opening template file #{@file}"
      if File.exists?(filename)
        template=File.new(filename).read
        result=ERB.new(template,nil,"-","@output").result(binding)
      end
      return result
    end

  end
end
