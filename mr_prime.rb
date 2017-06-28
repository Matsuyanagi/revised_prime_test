#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
#	ミラーラビンテストを使った素数判定
#	
#	
#	2017-05-16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#	Integer#mr_prime? ミラーラビンテストを利用した素数判定
#		ミラーラビンテストで素数判定された場合、強擬素数未満なら素数確定する
#-----------------------------------------------------------------------------
class Integer

	def mr_prime?
		# 3以下なら 2以上(2,3)は素数、それ以外(1,0,マイナス)は非素数
		return self >= 2 if self <= 3
		# (2をのぞく)偶数は合成数
		return false if self.even?
		
		#	2を底とする強擬素数
		#	Strong pseudoprimes to base 2.
		#	http://oeis.org/A001262
		#	>	2047, 3277, 4033, 4681, 8321, 15841, 29341, 42799, 49141, 52633, 65281, 74665, 80581, 85489, 88357, 90751, 104653, 130561, 196093, 220729, 233017, 252601, 253241, 256999, 271951, 280601, 314821, 357761, 390937, 458989, 476971, 486737
		#	これらを素因数分解すると 71 以下の素因数を持つものがある
		#	[ 2047, 3277, 4033, 4681, 8321, 15841, 29341, 42799, 49141, 52633, 65281, 74665, 80581, 85489, 88357, 90751, 104653, 130561, 196093, 220729, 233017, 252601, 253241, 256999, 271951, 280601, 314821, 357761, 390937, 458989, 476971, 486737 ].each{ |a| print "%5d : " % a; p a.prime_division } =>
		#	 2047 : [[23, 1], [89, 1]]
		#	 3277 : [[29, 1], [113, 1]]
		#	 4033 : [[37, 1], [109, 1]]
		#	 4681 : [[31, 1], [151, 1]]
		#	 8321 : [[53, 1], [157, 1]]
		#	15841 : [[7, 1], [31, 1], [73, 1]]
		#	29341 : [[13, 1], [37, 1], [61, 1]]
		#	42799 : [[127, 1], [337, 1]]			# 71 より大きい素因数を持つ最小の2を底とする強擬素数
		#	...
		
		# http://mathworld.wolfram.com/StrongPseudoprime.html
		#	Ψ20 まで
		#	[0] を底としてミラーラビンテストで「素数」判定されたとき、[1] (強擬素数)未満なら素数確定
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
			[ 71,	10 ** 36 ],
		]
		
		# base_prime_and_uppperbounds の[0]要素の素数に一致すれば素数
		if self <= base_prime_and_uppperbounds.last[ 0 ]
			# bsearch で二分探索する
			return true if base_prime_and_uppperbounds.bsearch{ |a| a[0] >= self } == self
		end
		
		# 素数で割り切れたら合成数( 71 以下の素数での除算試行 )
		base_prime_and_uppperbounds.each do |a|
			return false if self != a[0] && self % a[0] == 0
		end
		
		# 71 の次の素数、73 * 73 以下なら素数確定
		#	( 73 * 73 ) 未満で合成数であれば 71 以下の素因数を持ち、上記で合成数判定されているため
		#	base_prime_and_uppperbounds.last[ 0 ] (71)の次の素数(73) が計算で求まらない
		return true if self < 73 * 73
		
		# ミラーラビンテストで使用する d を求める
		# d : (self-1) = ( d*(2*r) ) を求める
		miller_rabin_d = self-1
		miller_rabin_d >>= 1 while miller_rabin_d.even?
		
		# 各 base を底としてミラーラビンテストをする
		base_prime_and_uppperbounds.each do | base, upper_bound|
			# base と self が素であることは保証されている
			
			# base においてミラーラビンテスト true で upper_bound 未満なら素数確定
			if miller_rabin_prime_test( base, miller_rabin_d )
				if self < upper_bound
					return true		# 素数確定
				end
			else
				return false		# 合成数確定
			end
		end
		# すべての底について true で通過
		
		# 高確率で素数ではあるが、合成数(強擬素数)の可能性がある
		#	ruby 2.4.1 の prime? の実装
		#	√self まで除算試行
		(7..Math.sqrt(self).to_i).step(30) do |p|
			return false if
				self%(p)	== 0 || self%(p+4)	== 0 || self%(p+6)	== 0 || self%(p+10) == 0 ||
				self%(p+12) == 0 || self%(p+16) == 0 || self%(p+22) == 0 || self%(p+24) == 0
		end
		true
	end
	
	# ミラーラビン素数判定
	#  wikipedia ベース
	#	https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95
	def miller_rabin_prime_test( base, miller_rabin_d )
		probable_prime = self
		
		t = miller_rabin_d
		y = self.powmod( base, t, probable_prime )
		while t != probable_prime-1 && y != 1 && y != probable_prime-1
			y = (y * y) % probable_prime
			t <<= 1
		end
		return false if y != probable_prime-1 && t.even?
		true
	end

	# ( base ** exp ) % mod
	#  wikipedia ベース
	#	 https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95
	# 本来なら base = 1,0 は特異であることをのぞいておく必要がある。ここでは来るはずはない
	def powmod( base, exp, mod )
		
		base = base % mod if base >= mod
		# base が mod の倍数、もしくは等しい場合を除いておく
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

