def find_project(project_name)
  # Tiek iegūts info par pieejamjiem projektiem
  response = get("http://apimation.com/projects",
                 cookies: @test_user.session_cookie)
  # Pārbaude vai var atrast info par projektiem
  assert_equal(200, response.code, "Neizdevās atrast projektus! #{response}")

  all_projects = JSON.parse(response)
  # Tiek izveitots tukšs projekta mainīgais
  current_project = nil
  # All projekts masīvā tiek meklēts projets pēc projekta nosaukuma
  all_projects.each do |find_projects|
    next unless find_projects['name'].to_s == project_name.to_s
    # Ja projekts tiek atrasts pēc nosakuma, tad projekta info tiek ierakstīts iekš current_project
    current_project = find_projects
  end
  # Ar izvēlētā projekta info tiek izveidots Project objekts
  Project.new(current_project)
end

def set_project_as_active(project_id)
  # Delete calls deaktivizē aktīvo projektu
  delete_active_project = delete("http://apimation.com/environments/active",
                                 cookies: @test_user.session_cookie)
  assert_equal(204, delete_active_project.code, "Probēma izdzēst aktīvo projektu! #{delete_active_project}")

  # Aktivizē izvēlēto projektu
  set_active_project = put("http://apimation.com/projects/active/#{project_id}",
                           cookies: @test_user.session_cookie)

  # Check if project is set to active
  assert_equal(204, set_active_project.code, "Problem to set active project! #{set_active_project}")
end

def create_new_environment(project, name)
  # Izveido jaunu environment payloadu
  new_project_payload = { 'name' => name }.to_json
  response = post("http://apimation.com/environments",
                  headers: { 'Content-Type' => 'application/json' },
                  cookies: @test_user.session_cookie,
                  payload: new_project_payload)
  # Pārbauda vai environment izveidots veiksmīgi
  assert_equal(200, response.code, "Problēma izveidot environmetu! #{response}")

  response_hash = JSON.parse(response)

  # Pievieno environmenta ID iekš projekta objekta
  project.environments.push(response_hash['id'])
end

def add_global_variable(environment_id, global_key, global_value)
  response = get("http://apimation.com/environments/#{environment_id[0]}",
                 cookies: @test_user.session_cookie)
  # Pārbauda vai info par attiecīgo environmentu ir iegūts veiksmīgi
  assert_equal(200, response.code, "Neizdevās iegūt info par environmentu !#{response}")

  response_hash = JSON.parse(response)
  # Iegūst info par esošajiem globālajiem mainīgajiem
  global_vars = response_hash['global_vars']
  # Pievieno jaunu info iekš esošā globālā mainīgo masīva
  global_vars.push({ 'key' => global_key, 'value' => global_value })
  # Izveido globālo mainīgo payloadu
  global_variable_payload = { 'global_vars' => global_vars }
  # Adding global variables to environments
  add_global_response = put("http://apimation.com/environments/#{environment_id[0]}",
                            headers: { 'Content-Type' => 'application/json' },
                            cookies: @test_user.session_cookie,
                            payload: global_variable_payload.to_json)
  # Pārbauda vai globālais mainīgais pievienots veiksmīgi
  assert_equal(204, add_global_response.code, "Problem adding apimation global variable! #{add_global_response}")
  @project.global_vars.push(response_hash['global_vars'])
end

def create_new_test_collection(collection_name, step_name)
  # Izveidoti payloada mainīgie
  request_url = nil
  body = nil
  method = nil
  # ifs, lai izveidotu specifiskas vērtības priekš step_payloada
  if collection_name == 'Login'
    request_url = "http://www.apimation.com/login"
    body = "{\"login\":\"#{@project.global_vars.last[0]['key']}\",\"password\":\"#{@project.global_vars.last[1]['key']}\"}\n"
    method = "POST"
  else
    request_url = "http://apimation.com/projects/active/#{@project.id}"
    body = ""
    method = "PUT"
end
  # Izveidots collection payloads
  test_collection_payload = {'name' => collection_name, 'description' => ''}

  # Tiek izveidots collection calls
  collection_response = post("http://apimation.com/collections",
                             headers: { 'Content-Type' => 'application/json' },
                             cookies: @test_user.session_cookie,
                             payload: test_collection_payload.to_json)
  # Tiek izveidots collection hash, lai pēc tam iegūtu collection ID
  collection_response_hash = JSON.parse(collection_response)
  # Pievieno kolekciju info iekš Projekta objekta
  @project.collections.push(collection_response_hash)

  # Tiek izveidots stepa payloads
  step_payload = {
      "name"=> step_name.to_s,
      "description"=> "",
      "request"=> {
          "method"=> method,
          "url"=> request_url,
          "type"=> "raw",
          "body"=> body,
          "binaryContent"=> {
              "value"=> "",
              "filename"=> ""
          },
          "urlEncParams"=> [
              {
                  "name"=> "",
                  "value"=> ""
              }
          ],
          "formData"=> [
              {
                  "type"=> "text",
                  "value"=> "",
                  "name"=> "",
                  "filename"=> ""
              }
          ],
          "headers"=> [
              {
                  "name"=> "Content-Type",
                  "value"=> "application/json"
              }
          ],
          "greps"=> [],
          "auth"=> {
              "type"=> "noAuth",
              "data"=> {}
          }
      },
      "paste"=> false,
      "collection_id"=> collection_response_hash['id'].to_s
  }

  # Tiek izveidots stepa calls
  step_response = post("http://apimation.com/steps",
                       headers: { 'Content-Type' => 'application/json' },
                       cookies: @test_user.session_cookie,
                       payload: step_payload.to_json)
  # Pārbaude vai steps izveidots veiksmīgi
  assert_equal(200, step_response.code, "Problēma izveidot jaunu soli! #{step_response}")
end

def delete_environment(environment_id)
  # Delete calls izdzēš environmentu
  delete_environment = delete("http://apimation.com/environments/#{environment_id[0]}",
                                 cookies: @test_user.session_cookie)
  # Pārbaude vai izvironments izdzēsts veiksmīgi
  assert_equal(204, delete_environment.code, "Probēma izdzēst Environmentu! #{delete_environment}")
end

def delete_all_collections
  # Collection calls, lai iegūtu
  collection_response = get("http://apimation.com/collections",
                            cookies: @test_user.session_cookie)
  assert_equal(200, collection_response.code, "Neizdevās atrast collections! #{collection_response}")
  # Izveidots collection hashs, lai tālāk atlasītu visus caollection ID
  collection_response_hash = JSON.parse(collection_response)
  # Visas kolekcijas tiek izdzēstas iziterējot cauri visiem ID un iesaistot ID collection DELETE calla
  collection_response_hash.each do |collection_ids|
    delete_environment = delete("http://apimation.com/collections/#{collection_ids['id']}",
                                cookies: @test_user.session_cookie)
    # Pārbauda vai collection izdzēšas
    assert_equal(204, delete_environment.code, "Probēma izdzēst collections! #{delete_environment}")
  end
end

def create_new_test_case(case_name)
  # Tiek izveidots jauna keisa payloads
  new_case_payload = {
      "name" => case_name,
      "description" => "this needs to be changed!!!",
      "request" => {
          "requests" => [
              {
                  "step_name" => "Login",
                  "url" => "http://www.apimation.com/login",
                  "body" => "{\"login\":\"#{@project.global_vars.last[0]['key']}\",\"password\":\"#{@project.global_vars.last[1]['key']}\"}\n",
                  "formData" => [
                      {
                          "type" => "text",
                          "value" => "",
                          "name" => "",
                          "filename" => ""
                      }
                  ],
                  "urlEncParams" => [
                      {
                          "name" => "",
                          "value" => ""
                      }
                  ],
                  "binaryContent" => {
                      "value" => "",
                      "filename" => ""
                  },
                  "type" => "raw",
                  "headers" => [
                      {
                          "name" => "Content-Type",
                          "value" => "application/json"
                      }
                  ],
                  "method" => "POST",
                  "greps" => [
                      {
                          "type" => "json",
                          "expression" => "",
                          "varname" => ""
                      }
                  ],
                  "asserts"=> []
              },
              {
                  "step_name" => "Set active project",
                  "url" => "http://apimation.com/projects/active/#{@project.id}",
                  "body" => "",
                  "formData" => [
                      {
                          "type" => "text",
                          "value" => "",
                          "name" => "",
                          "filename" => ""
                      }
                  ],
                  "urlEncParams" => [
                      {
                          "name" => "",
                          "value" => ""
                      }
                  ],
                  "binaryContent" => {
                      "value" => "",
                      "filename" => ""
                  },
                  "type" => "raw",
                  "headers"=> [
                      {
                          "name" => "Content-Type",
                          "value" => "application/json"
                      }
                  ],
                  "method" => "PUT",
                  "greps" => [
                      {
                          "type" => "json",
                          "expression" => "",
                          "varname" => ""
                      }
                  ],
                  "asserts" => []
              }
          ],
          "vars" => [
              {
                  "name" => "",
                  "value" => ""
              }
          ],
          "assertWarn" => 1
      }
  }
  # Calls priekš jaunā keisa
  new_case_response = post("https://apimation.com/cases",
                           headers: { 'Content-Type' => 'application/json' },
                           cookies: @test_user.session_cookie,
                           payload: new_case_payload.to_json)

  new_case_hash = JSON.parse(new_case_response)
  # Pārbauda vai keiss izveitos veiksmīgi
  assert_equal(200, new_case_response.code, "Problēma izveidot keisu! #{new_case_response}")
  # Pārbauda vai izveidotā keisa response nosaukums sakrīt ar ievadīto
  assert_equal(case_name.to_s, new_case_hash['name'].to_s, "Keisa nosaukums nesakrīt ar ievadīto! #{new_case_response}")

  # Izveidots GET calls, lai iegūtu info par izveidotajiem keisiem
  all_cases_response = get("http://apimation.com/cases",
                           cookies: @test_user.session_cookie)
  # Pārbauda vai info par keisiem iegūts veiksmīgi
  assert_equal(200, all_cases_response.code, "Problēma atrast keisus ! #{all_cases_response}")

  all_cases_hash = JSON.parse(all_cases_response)
  # Izveidot objekts ar false vērtību, lai izmantotu vēlāk pārbaudē
  created_case_id_match = false
  # Visu keisu masīvā meklē vai var atrast izveidotā keisa ID
  all_cases_hash.each do |find_case_id|
    next unless find_case_id['case_id'] == new_case_hash['case_id']
    created_case_id_match = true
  end
  # Pārbaude vai izveidotā keisa ID ir atrasts visu keisu masīvā
  assert_equal(true, created_case_id_match, "Nevar atrast izveidoto keisu!")
  # Pievieno case ID iekš projetka Objeta
  @project.cases.push(new_case_hash['case_id'])
end

def delete_cases
  # Iziet caur visiem esošajiem keisiem un izdzēš tos (zinu, ka pagaidām tikai viens :)
  @project.cases.each do |case_id|
  delete_case_response = delete("http://apimation.com/cases/#{case_id}",
                                cookies: @test_user.session_cookie)
  # Pābauda vai keisi ir idzēsušies
  assert_equal(204, delete_case_response.code, "Problēma izdzēst keisus! #{delete_case_response}")
  end
end