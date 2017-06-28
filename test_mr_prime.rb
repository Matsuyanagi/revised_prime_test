require 'test/unit'
require './mr_prime.rb'

class TC_MrPrime < Test::Unit::TestCase

	# n.prime? == n.mr_prime?
	def test_mr_prime_equal_prime
		( -10 ... 2_000_000 ).each do |number|
			assert_equal( number.prime?, number.mr_prime? )
		end
	end
	
	# 64bit prime test
	def test_64bit_prime
		assert_equal( true, 0xffffffffffffffad.mr_prime? )
	end
	
	# 65bit prime test
	def test_65bit_prime
		assert_equal( true, 0x1ffffffffffffffcf.mr_prime? )
	end
	
	# 10^36 prime test
	def test_10_36_prime
		assert_equal( true, 999999999999999999999999999999999841.mr_prime? )
	end
	
	
end



