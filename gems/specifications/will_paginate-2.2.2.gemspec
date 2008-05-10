Gem::Specification.new do |s|
  s.name = %q{will_paginate}
  s.version = "2.2.2"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mislav Marohni\304\207"]
  s.date = %q{2008-04-20}
  s.email = %q{mislav.marohnic@gmail.com}
  s.files = ["CHANGELOG", "LICENSE", "README.rdoc", "Rakefile", "examples", "examples/apple-circle.gif", "examples/index.haml", "examples/index.html", "examples/pagination.css", "examples/pagination.sass", "init.rb", "lib", "lib/will_paginate", "lib/will_paginate.rb", "lib/will_paginate/array.rb", "lib/will_paginate/collection.rb", "lib/will_paginate/core_ext.rb", "lib/will_paginate/finder.rb", "lib/will_paginate/named_scope.rb", "lib/will_paginate/named_scope_patch.rb", "lib/will_paginate/version.rb", "lib/will_paginate/view_helpers.rb", "test", "test/boot.rb", "test/collection_test.rb", "test/console", "test/database.yml", "test/finder_test.rb", "test/fixtures", "test/fixtures/admin.rb", "test/fixtures/developer.rb", "test/fixtures/developers_projects.yml", "test/fixtures/project.rb", "test/fixtures/projects.yml", "test/fixtures/replies.yml", "test/fixtures/reply.rb", "test/fixtures/schema.rb", "test/fixtures/topic.rb", "test/fixtures/topics.yml", "test/fixtures/user.rb", "test/fixtures/users.yml", "test/helper.rb", "test/lib", "test/lib/activerecord_test_case.rb", "test/lib/activerecord_test_connector.rb", "test/lib/load_fixtures.rb", "test/lib/view_test_process.rb", "test/view_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mislav/will_paginate}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{will-paginate}
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{Most awesome pagination solution for Rails}
end
