Before() do
  # Before hooks izveidot globālo mainīgo ar User objektu
  @test_user = User.new('gatis.vaitovskis@gmail.com', 'password')
end

After() do
  # After hooks izdzēš environmentu un visas kolekcijas
  delete_environment(@project.environments)
  delete_all_collections
end