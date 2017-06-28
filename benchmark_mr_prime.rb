require 'prime'
require 'benchmark'
require './mr_prime.rb'

def main( n )
	
	puts n
	result = Benchmark.realtime do
		puts n.mr_prime?
	end
	puts "mr_prime? 処理 #{result}s"
	
end

main( 0xffffffffffffffad )



