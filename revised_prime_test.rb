#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
#	ミラーラビンテストを使った素数判定
#	
#	
#	2017-05-16
#-----------------------------------------------------------------------------
require 'pp'
require 'prime'
require 'benchmark'

Encoding.default_external="utf-8"
#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
settings = {
	
}



#-----------------------------------------------------------------------------
# 
#-----------------------------------------------------------------------------
class Integer

	def rev_prime?
		# 3以下なら 2以上(2,3)は素数、それ以外(1,0,マイナス)は合成数
		return self >= 2 if self <= 3
		# (2以外の)偶数は合成数
		return false if self.even?
		# 5,7 は素数
		return true if self <= 7
		
		# これらの数値を底としてテストに通過すれば 2^64 までの数値では素数として確定する
		[ 2, 325, 9375, 28178, 450775, 9780504, 1795265022 ].each do |base|
			break if self.gcd( base ) == [ self, base ].min
			
			return false unless miller_rabin_prime_test( base )
		end
		
		# すべての底について true で通過した
		# self が 2^64 以下なら素数は確定
		return true if self < 2 ** 64
		
		# 高確率で素数ではあるが、合成数の可能性がある 2^64 より大きい数値
		
		return true ; #?
	end

	# ミラーラビン素数判定
	def miller_rabin_prime_test( base )
		probable_prime = self
		
	    # https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test#Ruby ベース
	    d = probable_prime-1
	    d >>= 1 while d.even?
	    
	    t = d
	    y = self.powmod( base, t, probable_prime )
	    while t != probable_prime-1 && y != 1 && y != probable_prime-1
	        y = (y * y) % probable_prime
	        t <<= 1
	    end
	    return false if y != probable_prime-1 && t.even?
	    return true
	end


	# ( base ** exp ) % m
	#  wikipedia ベース
	#    https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95
	def powmod( base, exp, m )
		
		base = base % m if base >= m
		return 0 if base.zero?
		
		answer = 1
		while exp > 0
			answer = ( answer * base ) % m if exp.odd?
			base = ( base * base ) % m
			exp >>= 1
		end
		answer
	end
end


#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
def main( settings )
	
	
	
	( 1 ... 2000000 ).each do |n|
#	( 1000000 ... 20000000 ).each do |n|
		puts( "#{n}" ) if n % 100000 == 0
		
		p = n.prime?
		r = n.rev_prime?
		if p != r
			puts( "----" )
			puts( "#{n} : #{p} , #{r}" )
		end
		
		
	end
	
	
	
	
end

# main( settings )

def main2( settings )
	
	result = Benchmark.realtime do
		( 1+1_0000_0000 ... 100_0000+1_0000_0000 ).each do |n|
			p = (n*2+1).prime?
		end
	end
	puts "prime? 処理概要 #{result}s"
	
	result = Benchmark.realtime do
		( 1+1_0000_0000 ... 100_0000+1_0000_0000 ).each do |n|
			p = (n*2+1).rev_prime?
		end
	end
	puts "rev_prime? 処理概要 #{result}s"
	
	
end

main2( settings )



