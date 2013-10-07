def quickbm(repetitions = 100, &block)
  require 'benchmark'

  Benchmark.bm do |bm|
    bm.report { repetitions.times(&block) }
  end
end
