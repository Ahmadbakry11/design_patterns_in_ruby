class Report
  def initialize
    @title = "Monthly Report"
    @text = ['Things are going', 'really, really well.']
  end

  def output_report
    output_start
    output_head
    output_body_start
    output_body
    output_body_end
    output_end
  end
  
  def output_start   #hook method, override or accept defaults
  end

  def output_head   #abstract method, you need to override
    output_line(@title)
  end

  def output_body_start #hook method, override or accept defaults
  end

  def output_body
    @text.each do |line|
      output_line(line)
    end
  end

  def output_line(line)  #abstract method, you need to override
    raise 'called abstract method: output_line'
  end 

  def output_body_end  #hook method, override or accept defaults
  end

  def output_end    #hook method, override or accept defaults
  end
end

class HtmlReport < Report
  def output_start
    puts '<HTML>'
  end

  def output_head
    puts '<head>'
    puts "<title>#{@title}</title>"
    puts '</head>'
  end 

  def output_body_start
    puts '<body>'
  end

  def output_line(line)
    puts "<p>#{line}</p>"
  end

  def output_body_end
    puts '</body>'
  end

  def output_end
    puts '</HTML>'
  end 
end 

class PlainTextReport < Report 
  def output_line(line)
    puts line
  end 
end 

plain_text_report = PlainTextReport.new 
plain_text_report.output_report

html_report = HtmlReport.new 
html_report.output_report