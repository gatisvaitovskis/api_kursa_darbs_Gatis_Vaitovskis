class Project

  attr_accessor :id
  attr_accessor :name
  attr_accessor :environments
  attr_accessor :collections
  attr_accessor :cases

  def initialize(project)
    @id = project['id']
    @name = project['name']
    @environments = []
    @collections = []
    @cases = []
  end
end