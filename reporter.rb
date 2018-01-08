require 'json'
require 'report_builder'
require_relative 'features/support/api_helper.rb'

# Jenkins env manīgie
job_name = ARGV[0]
build_number = ARGV[1]

# Generate HTML report
ReportBuilder.configure do |config|
  config.json_path = 'report.json'
  config.report_path = 'kursa_darbs_gatis_vaitovskis'
  config.report_types = [:html]
  config.report_tabs = %w[Overview Features Scenarios Errors]
  config.report_title = 'Cucumber web automation test results'
  config.compress_images = false
  config.additional_info = { 'Project' => job_name}
end

ReportBuilder.build_report

passed_cases = 0
failed_cases = 0

# Mainīgajā tiek ielasīts html reports
report = File.open('kursa_darbs_gatis_vaitovskis.html').read

# Iziet cauri katrai reporta līnijai un atrod failed keisus
report.each_line do |line|
  failed_cases += 1 if line.match(/<tr class="failed">/)
end
# Iziet cauri katrai reporta līnijai un atrod passed keisus
report.each_line do |line|
  passed_cases += 1 if line.match(/<tr class="passed">/)
end

# Saskaita visus keisu kopā
all_cases = passed_cases.to_i + failed_cases.to_i

# Tiek saskaitīti visi scenārīji kopā
all_cases = passed_cases.to_i + failed_cases.to_i
# Tiek izrēķināti pass rate un failed rate %
pass_rate_percentage = (passed_cases.to_f / all_cases.to_f * 100).round(2)
failed_rate_percentage = (failed_cases.to_f / all_cases.to_f * 100).round(2)
# Tiek izveidots cucumber reporta links
cucumber_report_link = "http://jenkinsautomation.tdlbox.com/job/Kursa_darbs_Gatis_Vaitovskis/job/Kursa_darbs_Jenkins_Job_Gatis_Vaitovskis/ #{build_number.to_s}/cucumber-html-reports/overview-features.html"

fields = []
# fields masīvā tiek salikts viss nepieciešamais info kam jāparādas čatā
fields.push({ 'name' => 'Job name','value' => job_name.to_s })
fields.push({ 'name' => 'Build number', 'value' => build_number.to_s })
fields.push({ 'name' => 'Cucumber report link', 'value' => cucumber_report_link.to_s })
fields.push({ 'name' => 'Pass rate','value' => pass_rate_percentage.to_s + '%'})
fields.push({ 'name' => 'Failed rate','value' => failed_rate_percentage.to_s + '%'})
fields.push({ 'name' => 'Passed','value' => passed_cases.to_s})
fields.push({ 'name' => 'Failed','value' => failed_cases.to_s})
fields.push({ 'name' => 'Total','value' => all_cases.to_s})

embed = []
thumbnail = { 'url' => 'http://www.freepngimg.com/download/assault%20rifle/6-ak-47-kalash-russian-assault-rifle-png.png' }
embed.push({ 'color' => 16024386,
             'fields' => fields,
             'thumbnail' => thumbnail })

payload = { 'content' => 'Gatis Vaitovskis', 'embeds' => embed }.to_json

response = post('https://discordapp.com/api/webhooks/393067525451022336/uz2WgUi_8-6oS9zy2Pu_3l_-CtQvabdSlgflF_ojyxTxWgxO_8Vdj0qBDMNixDj6wlT1',
                headers: { 'Content-Type' => 'application/json' },
                cookies: {},
                payload: payload)