require "bundler/gem_tasks"
require "stackprof"
require "rack/test"

task :make_dump do
  class DummyA
    def work
      sleep 0.01
    end
  end

  class DummyB
    def work
      DummyA.new.work
    end
  end

  StackProf.run(mode: :cpu, out: 'spec/fixtures/test.dump') do
    1000.times { DummyB.new.work }
  end
end
