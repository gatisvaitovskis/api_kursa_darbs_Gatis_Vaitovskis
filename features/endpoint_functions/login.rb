require 'rest-client'
require 'test-unit'

def login_positive
  login_payload = { login: @test_user.email,
                    password: @test_user.password }.to_json
  # Login POST calls
  response = post('http://www.apimation.com/login',
                  headers: { 'Content-Type' => 'application/json' },
                  cookies: {},
                  payload: login_payload)
  # Pārbaude priekš login calla
  assert_equal(200, response.code, "Ielogošanās neizdevās #{response}")

  @test_user.set_session_cookie(response.cookies)

  # Pārveido JSON responsu par hashu
  response_hash = JSON.parse(response)
  # Ielasa userID iekš User objekta
  @test_user.set_user_id(response_hash['user_id'])
  # Pārbauda vai User objekta epasts sakrīt ar response epastu
  assert_equal(@test_user.email, response_hash['email'], 'e - pasts nav  pareizs !')
  # Pārbauda vai responsā parādas userID
  assert_not_equal(nil, response_hash['user_id'], 'User ID nav !')
end