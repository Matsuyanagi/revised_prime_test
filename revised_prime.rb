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

	def rev_prime2?
		# 3以下なら 2以上(2,3)は素数、それ以外(1,0,マイナス)は合成数
		return self >= 2 if self <= 3
		# (2をのぞく)偶数は合成数
		return false if self & 1 == 0
		
		# http://mathworld.wolfram.com/StrongPseudoprime.html より
		#
		#	2を底とする強擬素数
		#	Strong pseudoprimes to base 2.
		#	http://oeis.org/A001262
		#	>	2047, 3277, 4033, 4681, 8321, 15841, 29341, 42799, 49141, 52633, 65281, 74665, 80581, 85489, 88357, 90751, 104653, 130561, 196093, 220729, 233017, 252601, 253241, 256999, 271951, 280601, 314821, 357761, 390937, 458989, 476971, 486737
		#	[ 2047, 3277, 4033, 4681, 8321, 15841, 29341, 42799, 49141, 52633, 65281, 74665, 80581, 85489, 88357, 90751, 104653, 130561, 196093, 220729, 233017, 252601, 253241, 256999, 271951, 280601, 314821, 357761, 390937, 458989, 476971, 486737 ].each{ |a| print "%5d : " % a; p a.prime_division }
		#	 2047 : [[23, 1], [89, 1]]
		#	 3277 : [[29, 1], [113, 1]]
		#	 4033 : [[37, 1], [109, 1]]
		#	 4681 : [[31, 1], [151, 1]]
		#	 8321 : [[53, 1], [157, 1]]
		#	15841 : [[7, 1], [31, 1], [73, 1]]
		#	29341 : [[13, 1], [37, 1], [61, 1]]
		#	42799 : [[127, 1], [337, 1]]			# 71 より大きい素因数を持つ最小の2を底とする強擬素数
		
		# http://mathworld.wolfram.com/StrongPseudoprime.html
		#	Ψ20 まで
		#	↓を底としてmillerテスト	↓この数(強擬素数)未満なら素数確定
		base_prime_and_uppperbounds = [
			[ 2,	42799 ],		# 2の強擬素数 : 2047 = 23 * 89 : 強擬素数だが 71 までの除算で合成数判定されている
									# 42799.prime_division => [[127, 1], [337, 1]] : 71 より大きい素因数を持つ最小の「2を底とする強擬素数」
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
			[ 71,	10 ** 36 ],		# 10^36 ≒ 2**119.59
		]
		
		# base_prime_and_uppperbounds の[0]要素の素数に一致すれば素数
		if self <= base_prime_and_uppperbounds.last[ 0 ]
			# bsearch で二分探索する
			return true if base_prime_and_uppperbounds.bsearch{ |a| a[0] >= self } == self
		end
		
		# 素数で割り切れたら合成数
		base_prime_and_uppperbounds.each do |a|
			return false if self != a[0] && self % a[0] == 0
		end
		
		# 71 の次の素数、73 * 73 以下なら素数確定
		#	base_prime_and_uppperbounds.last[ 0 ] (71) の次の素数(73) を求めるのは難しいか
		return true if self < 73 * 73
		
	    # ミラーラビンテストで使用する d を求める
	    # d : (p-1)^( d*(2*r) ) を求める
	    # base ^ ( p-1 ) : p-1 = d*(2*r)
	    # d : p-1 = d*(2*r) を求める
	    miller_rabin_d = self-1
	    miller_rabin_d >>= 1 while miller_rabin_d.even?
		
		# 
		base_prime_and_uppperbounds.each do | base, upper_bound|
			
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


