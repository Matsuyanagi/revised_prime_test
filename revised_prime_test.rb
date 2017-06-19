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

	def rev_prime2?
		# 3以下なら 2以上(2,3)は素数、それ以外(1,0,マイナス)は合成数
		return self >= 2 if self <= 3
		# (2をのぞく)偶数は合成数
		return false if self & 1 == 0
#		# 5,7は素数
#		return true if self == 5 || self == 7
		
		# 偶数,3,5 の倍数は合成数
		#	1 - ( 概算:素数の可能性 1/2 * 2/3 * 4/5 ) = 11/15  合成数確定 11/15 ≒ 0.73
		# return false if ( self & 1 == 0 || self % 3 == 0 || ( self % 5 == 0 ) )
		
		# 2,3,5 の倍数はすでに合成数として判定済みなので 5,7,11,13,17,19,23,29,31,37,41,43,47 (7*7未満)まで素数確定
		# return true if self < 7 * 7
		
		# 7 は素数
		# return true if self <= 7
		# self % 7 == 0 # 7の倍数まで判定すれば (11*11未満) 121 未満まで素数確定する
		#	1-( 1/2r * 2/3r * 4/5r * 6/7r ) => (27/35) ≒ 0.77
		
#		# 3 * 5 * 7 と素ではないなら合成数
#		return false if ( self % 3 == 0 || self % 5 == 0 || self % 7 == 0 )
		
		# GCD とかややこしいことをしなくても大丈夫?
		#	大きい数値の場合はどういう演算になるだろう
		# return false unless gcd( self, 3 * 5 * 7 ) == 1
		
#		# 2,3,5,7 の倍数はすでに合成数として判定済みなので (11*11未満)まで素数確定
#		return true if self < 11 * 11
		
		
		# 3,5,7,11,13,17,19,23 は素数
		return true if self == 5 || self == 7 || self == 11 || self == 13 || self == 17 || self == 19 || self == 23
		
		# 3,5,7,11,13,19,23 との GCD での疎判定をする。約数に持てば合成数確定
		return false unless self.gcd( 3 * 5 * 7 * 11 * 13 * 17 * 19 * 23 ) == 1 # 111546435 = "6a61043"
		
		# 29x29 未満は素数確定
		return true if self < 29 * 29
		
		
		
	    # ミラーラビンテストで使用する d を求める
	    # d : (p-1)^( d*(2*r) ) を求める
	    # base ^ ( p-1 ) : p-1 = d*(2*r)
	    # d : p-1 = d*(2*r) を求める
	    miller_rabin_d = self-1
	    miller_rabin_d >>= 1 while miller_rabin_d.even?
		
		# http://mathworld.wolfram.com/StrongPseudoprime.html より
		#	↓でmillerテスト	↓これ未満なら素数確定
		# Struct 作るべきか?
		#		2047 = 23 * 89 なのでミラーラビンテストの前に 23 で割っていれば 2 の強擬素数はもっと大きい
		#	http://primes.utm.edu/glossary/xpage/StrongPRP.html
		#		2	2047, 3277, 4033, 4681, 8321, 15841	0.07 %
		#		3277 = 29 * 113
		# 2047.prime_division					=> [[23, 1], [89, 1]]
		# 3277.prime_division					=> [[29, 1], [113, 1]]
		# 1373653.prime_division				=> [[829, 1], [1657, 1]]
		# 25326001.prime_division				=> [[2251, 1], [11251, 1]]
		# 3215031751.prime_division				=> [[151, 1], [751, 1], [28351, 1]]
		# 2152302898747.prime_division			=> [[6763, 1], [10627, 1], [29947, 1]]
		# 3474749660383.prime_division			=> [[1303, 1], [16927, 1], [157543, 1]]
		# 341550071728321.prime_division		=> [[10670053, 1], [32010157, 1]]
		# 3825123056546413051.prime_division	=> [[149491, 1], [747451, 1], [34233211, 1]]
		# 318665857834031151167461				=> 399165290221 * 798330580441
		# 3317044064679887385961981				=> 1287836182261 * 2575672364521
		# 6003094289670105800312596501			=> 54786377365501 * 109572754731001
		# 59276361075595573263446330101			=> 172157429516701 * 344314859033401
		# 564132928021909221014087501701		=> 531099297693901 * 1062198595387801
		# 1543267864443420616877677640751301	=> 27778299663977101 * 55556599327954201
		
		base_and_uppperbounds = [
#			[ 2,	2047 ],
			[ 2,	3277 ],		# 2047 = 23 * 89, 3277 = 29 * 113 : 2の強擬素数
			[ 3,	1373653 ],
			[ 5,	25326001 ],
			[ 7,	3215031751 ],
			[ 11,	2152302898747 ],
			[ 13,	3474749660383 ],
			[ 17,	341550071728321 ],
			[ 19,	341550071728321 ],
			[ 23,	3825123056546413051 ],
			[ 29,	3825123056546413051 ],
			[ 31,	3825123056546413051 ],
			[ 37,	318665857834031151167461 ],
			[ 41,	3317044064679887385961981 ],
			[ 43,	6003094289670105800312596501 ],
			[ 47,	59276361075595573263446330101 ],
			[ 53,	564132928021909221014087501701 ],
			[ 59,	564132928021909221014087501701 ],
			[ 61,	1543267864443420616877677640751301 ],
			[ 67,	1543267864443420616877677640751301 ],
			[ 71,	10 ** 36 ],		# 10^36 ≒ 2**119
		]
		
		# 
		base_and_uppperbounds.each do | base, upper_bound|
			
			# base と self が素であることを確認する
			# 割り切れるなら (base の倍数であるなら) 合成数確定
			# 23までは上記で gcd 判定している
			if base > 23
				return false if self % base == 0
			end
			
			# base においてミラーラビンテスト true で upper_bound 未満なら素数確定
			if miller_rabin_prime_test( base, miller_rabin_d )
				if self < upper_bound
					return true		# 素数確定
				end
			else
				return false		# 合成数確定
			end
		end
		# すべての底について true で通過した
		
		# 高確率で素数ではあるが、合成数(強擬素数)の可能性がある
		
		
		return true ; #?
	end
	
	# 本来なら base = 1,0 は特異であることをのぞいておく必要がある。ここでは来るはずはないのだが
	
	
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


	# 本来なら base = 1,0 は特異であることをのぞいておく必要がある。ここでは来るはずはないのだが
	
	# ( base ** exp ) % mod
	#  wikipedia ベース
	#    https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95
	def powmod( base, exp, mod )
		
		# base が mod の倍数、もしくは等しい場合を除いておく
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
#			r = number.rev_prime?
			r = number.rev_prime2?
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
#	range_upper = 0 + 200_0000
	range_upper = 0 + 100_0000
	
	result = Benchmark.realtime do
		( range_lower ... range_upper ).each do |n|
			p = (n*2+1).prime?
		end
	end
	puts "prime? 処理概要 #{result}s"
	
	result = Benchmark.realtime do
		( range_lower ... range_upper ).each do |n|
#			p = (n*2+1).rev_prime?
			p = (n*2+1).rev_prime2?
		end
	end
	puts "rev_prime? 処理概要 #{result}s"
	
	
end

# main2( settings )

def main3( n )
	
	result = Benchmark.realtime do
		puts n
		puts n.rev_prime2?
	end
	puts "rev_prime2? 処理概要 #{result}s"
	
	
end

main3( 18446744073709551533 )



