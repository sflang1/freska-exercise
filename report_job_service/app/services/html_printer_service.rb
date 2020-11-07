class HtmlPrinterService < ApplicationService
  attr_reader :historical

  def initialize(historical)
    @historical = historical
  end

  def call
    @historical.map do |currency, data|
      filename = File.join(__dir__, '..', '..', 'tmp', "#{currency}_evolution_#{Date.today.strftime("%Y-%m-%d")}.html")
      File.open(filename, 'w') do |f|
        f.write('<html>')
        f.write('<body>')
        f.write('<table>')
        f.write('<thead>')
        f.write('<tr>')
        f.write('<th>Date reported</th>')
        f.write('<th>Currency value today</th>')
        f.write('<th>Currency value that day</th>')
        f.write('<th>Delta</th>')
        f.write('</tr>')
        f.write('</thead>')
        f.write('<tbody>')
        data.each do |row|
          f.write('<tr>')
          f.write("<td>#{row[:report_date]}</td>")
          f.write("<td>#{row[:currency_today]}</td>")
          f.write("<td>#{row[:currency_that_date]}</td>")
          f.write("<td>#{row[:delta]}</td>")
          f.write('</tr>')
        end
        f.write('</tbody>')
        f.write('</table>')
        f.write('</body>')
        f.write('</html>')
      end
      filename
    end
  end
end