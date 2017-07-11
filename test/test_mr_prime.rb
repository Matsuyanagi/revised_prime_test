require 'prime'
require 'test/unit'
require '../mr_prime.rb'

class TC_MrPrime < Test::Unit::TestCase

    # n.prime? == n.mr_prime?
    def test_mr_prime_equal_prime
        ( -10 ... 2_000_000 ).each do |number|
            assert_equal( number.prime?, number.mr_prime? )
        end
    end
    
    # 64bit prime number test
    def test_64bit_prime
        assert( 0xffffffffffffffad.mr_prime? )
    end
    
    # 65bit prime number test
    def test_65bit_prime
        assert( 0x1ffffffffffffffcf.mr_prime? )
    end
    
    # 10^36 prime number test
    def test_10_36_prime
        assert( 999999999999999999999999999999999841.mr_prime? )
    end
    
	# 128 bit prime number test
	def test_128bit_prime
		assert( 340282366920938463463374607431768211283.mr_prime? )
		assert( 340282366920938463463374607431768211223.mr_prime? )
		assert( 340282366920938463463374607431768211219.mr_prime? )
		assert( 340282366920938463463374607431768211181.mr_prime? )
		assert( 340282366920938463463374607431768211099.mr_prime? )
		assert( 340282366920938463463374607431768210781.mr_prime? )
		assert( 340282366920938463463374607431768210743.mr_prime? )
		assert( 340282366920938463463374607431768210659.mr_prime? )
		assert( 340282366920938463463374607431768210263.mr_prime? )
	end


end
