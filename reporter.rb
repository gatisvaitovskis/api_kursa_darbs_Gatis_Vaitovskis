require 'json'
require_relative 'features/support/api_helper.rb'
# Jenkins env manīgie
job_name = ARGV[0]
build_number = ARGV[1]
build_url = ARGV[2]

# Mainīgajā tiek ielasīts report failu
report = File.open('report.json').read

# Ar regexu tiek meklēti passed un failed scenārīji
passed_scenarious_count = report.scan(/\bpassed/).size.to_i
failed_scenarious_count = report.scan(/\bfailed/).size.to_i
# Tiek saskaitīti visi scenārīji kopā
all_scenarious = passed_scenarious_count + failed_scenarious_count
# Tiek izrēķināti pass rate un failed rate %
pass_rate_percentage = (passed_scenarious_count.to_f / all_scenarious.to_f * 100).round(2)
failed_rate_percentage = (failed_scenarious_count.to_f / all_scenarious.to_f * 100).round(2)
# Tiek izveidots cucumber reporta links. Build URL tiek ņemts no Jenkins env mainīgajiem
cucumber_report_link = build_url + 'cucumber-html-reports/overview-features.html'

thumbnail = { 'url' => 'http://www.freepngimg.com/download/assault%20rifle/6-ak-47-kalash-russian-assault-rifle-png.png' }
fields = []
# fields masīvā tiek salikts viss nepieciešamais info kam jāparādas čatā
fields.push({ 'name' => 'Job name','value' => job_name.to_s })
fields.push({ 'name' => 'Build number', 'value' => build_number.to_s })
fields.push({ 'name' => 'Cucumber report link','value' => cucumber_report_link.to_s })
fields.push({ 'name' => 'Pass rate','value' => pass_rate_percentage.to_s + '%'})
fields.push({ 'name' => 'Failed rate','value' => failed_rate_percentage.to_s + '%'})
fields.push({ 'name' => 'Total','value' => all_scenarious.to_s})
fields.push({ 'name' => 'Passed','value' => passed_scenarious_count.to_s})
fields.push({ 'name' => 'Failed','value' => failed_scenarious_count.to_s})


embed = []
embed.push({ 'color' => 16024386,
             'fields' => fields,
             'thumbnail' => thumbnail })


payload = { 'content' => 'Gatis Vaitovskis', 'embeds' => embed }.to_json

response = post('https://discordapp.com/api/webhooks/393067525451022336/uz2WgUi_8-6oS9zy2Pu_3l_-CtQvabdSlgflF_ojyxTxWgxO_8Vdj0qBDMNixDj6wlT1',
                headers: { 'Content-Type' => 'application/json' },
                cookies: {},
                payload: payload)

