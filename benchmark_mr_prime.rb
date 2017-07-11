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
main( 1_000_000_000_000_000_003 )
main( 340282366920938463463374607431768211283 )



