When(/^I find and activate project: (.*)$/) do |project_name|
  @project = find_project(project_name)
  set_project_as_active(@project.id)
end

And(/^I create new environment: (.*)/) do |name|
  create_new_environment(@project, name)
end

Then(/^I add global variable: (.*) with value: (.*)$/) do |name, value|
  case
    when name != '$project_id'
      add_global_variable(@project.environments, name, value)
    else
      add_global_variable(@project.environments, name, @project.id.to_s)
  end
end

And(/^I create new collection: (.*) with step: (.*)$/) do |collection_name, step_name|
  create_new_test_collection(collection_name, step_name)
end

Then(/^I create new test case: (.*)$/) do |case_name|
  create_new_test_case(case_name)
end