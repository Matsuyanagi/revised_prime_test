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
		# 5は素数
		return true if self == 5
		# 偶数,3,5 の倍数は合成数
		#	1 - ( 概算:素数の可能性 1/2 * 2/3 * 4/5 ) = 11/15  合成数確定 11/15 ≒ 0.73
		return false if ( self & 1 == 0 || self % 3 == 0 || ( self % 5 == 0 ) )
		
		# 2,3,5 の倍数はすでに合成数として判定済みなので 5,7,11,13,17,19,23,29,31,37,41,43,47 (7*7未満)まで素数確定
		return true if self < 7 * 7
		
		# 7 は素数
		#	return true if self <= 7
		# self % 7 == 0 # 7の倍数まで判定すれば (11*11未満) 121 未満まで素数確定する
		#	1-( 1/2r * 2/3r * 4/5r * 6/7r ) => (27/35) ≒ 0.77
		# 2,3,5,7 の倍数はすでに合成数として判定済みなので (11*11未満)まで素数確定
		# return true if self < 11 * 11
		
		
	    # ミラーラビンテストで使用する d を求める
	    # d : (p-1)^( d*(2*r) ) を求める
	    # base ^ ( p-1 ) : p-1 = d*(2*r)
	    # d : p-1 = d*(2*r) を求める
	    miller_rabin_d = self-1
	    miller_rabin_d >>= 1 while miller_rabin_d.even?
		
		# これらの数値を底としてテストに通過すれば 2^64 までの数値では素数として確定する
		#	? 合成数を底とする場合、判定には底と判定対象が素であることを確認する
		#	底の倍数は判定しない  base ** ( base-1 ) mod base = 0
		#	素数はこのループをすべて通る。上記で判定していなければ 11 なども
		[ 2, 325, 9375, 28178, 450775, 9780504, 1795265022 ].each do |base|
			# 底(base)と self(素数判定対象) が小さい方で割り切れるなら、倍数なのでこの底を用いての判定はしない
#			break if self.gcd( base ) == [ self, base ].min
			break if ( self > base ) ? self % base == 0 : base % self == 0
			# 指定された底を利用して self のミラーラビンテストを行う
			#	miller_rabin_prime_test() #=> false なら合成数確定
			return false unless miller_rabin_prime_test( base, miller_rabin_d )
		end
		
		# すべての底について true で通過した
		# self が 2^64 以下なら素数は確定
		return true if self < 2 ** 64
		
		# 高確率で素数ではあるが、合成数の可能性がある 2^64 より大きい数値
		
		
		return true ; #?
	end

	# ミラーラビン素数判定
	def miller_rabin_prime_test( base, miller_rabin_d )
		probable_prime = self
		
	    # https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test#Ruby ベース
#	    miller_rabin_d = probable_prime-1
#	    miller_rabin_d >>= 1 while miller_rabin_d.even?
	    
	    t = miller_rabin_d
	    y = self.powmod( base, t, probable_prime )
	    while t != probable_prime-1 && y != 1 && y != probable_prime-1
	        y = (y * y) % probable_prime
	        t <<= 1
	    end
	    return false if y != probable_prime-1 && t.even?
	    return true
	end


	# ( base ** exp ) % mod
	#  wikipedia ベース
	#    https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95
	def powmod( base, exp, mod )
		
		base = base % mod if base >= mod
		return 0 if base.zero?
		
		answer = 1
		while exp > 0
			answer = ( answer * base ) % mod if exp.odd?
			base = ( base * base ) % mod
			exp >>= 1
		end
		answer
	end
end


#-----------------------------------------------------------------------------
#	
#-----------------------------------------------------------------------------
def main( settings )
	
	
	
	result = Benchmark.realtime do
		( 1 ... 200_0000 ).each do |n|
	#	( 100_0000 ... 2000_0000 ).each do |n|
			puts( "#{n}" ) if n % 100000 == 0
			
			number = (n*2+1)
			p = number.prime?
			r = number.rev_prime?
			if p != r
				puts( "----" )
				puts( "#{number} : #{p} , #{r}" )
			end
			
			
		end
	end
	puts "rev_prime? 処理概要 #{result}s"
	
	
	
	
end

# main( settings )

def main2( settings )
	
#	range_lower = 1_0000_0000 + 1
#	range_upper = 1_0000_0000 + 100_0000
	range_lower = 0 + 1
	range_upper = 0 + 200_0000
	
	result = Benchmark.realtime do
		( range_lower ... range_upper ).each do |n|
			p = (n*2+1).prime?
		end
	end
	puts "prime? 処理概要 #{result}s"
	
	result = Benchmark.realtime do
		( range_lower ... range_upper ).each do |n|
			p = (n*2+1).rev_prime?
		end
	end
	puts "rev_prime? 処理概要 #{result}s"
	
	
end

main2( settings )



