Feature: 2. Uzdevums

  Scenario: 2.Uzdevums
    When I login apimation
    Then I find and activate project: API kursa darbs
    And I create new environment: PREPROD
    Then I add global variable: $user with value: gatis.vaitovskis@gmail.com
    Then I add global variable: $password with value: password
    Then I add global variable: $project_id with value: current_id
    And I create new collection: Login with step: Login
    And I create new collection: Projects  with step: Set active project