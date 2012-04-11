Gem::Specification.new do |s|
  s.name    = %q{garry}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors     = ["Ken Erickson"]
  s.date        = %q{2012-04-10}
  s.description = %q{An ecommerce framework powered by padrino, mongomapper & stripe}
  s.email       = %q{bookworm.productions@gmail.com}      
  
  s.files            = `git ls-files`.split("\n")
  s.homepage         = %q{http://github.com/bookworm/garry}
  s.require_paths    = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary    = %q{An ecommerce framework powered by padrino, mongomapper & stripe}
  s.test_files = [
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<padrino>, [">= 0.10.2"])
    else
      s.add_dependency(%q<padrino>, [">= 0.10.2"])
    end
  else
    s.add_dependency(%q<padrino>, [">= 0.10.2"])
  end
end