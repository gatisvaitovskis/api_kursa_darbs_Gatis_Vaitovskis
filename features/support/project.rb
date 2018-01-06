class Project

  attr_accessor :id
  attr_accessor :name
  attr_accessor :environments

  def initialize(project)
    @id = project['id']
    @name = project['name']
    @environments = []
  end
end