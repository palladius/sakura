#!/usr/bin/python

#MAX=${1:-100}

# see https://www.youtube.com/watch?v=NaL_Cb42WyY
# https://stackoverflow.com/questions/567222/simple-prime-generator-in-python
import math

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKRED = '\033[91m'
    OKGREEN = '\033[92m'
    OKYELLOW = '\033[93m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def primes(n): # simple Sieve of Eratosthenes 
	'''inefficiente ma va bene.'''
	odds = range(3, n+1, 2)
	sieve = set(sum([range(q*q, n+1, q+q) for q in odds],[]))
	return [2] + [p for p in odds if p not in sieve]

def gen_primes():
    """ Generate an infinite sequence of prime numbers.
    """
    # Maps composites to primes witnessing their compositeness.
    # This is memory efficient, as the sieve is not "run forward"
    # indefinitely, but only as long as required by the current
    # number being tested.
    #
    D = {}
    
    # The running integer that's checked for primeness
    q = 2
    
    while True:
        if q not in D:
            # q is a new prime.
            # Yield it and mark its first multiple that isn't
            # already marked in previous iterations
            # 
            yield q
            D[q * q] = [q]
        else:
            # q is composite. D[q] is the list of primes that
            # divide it. Since we've reached q, we no longer
            # need it in the map, but we'll mark the next 
            # multiples of its witnesses to prepare for larger
            # numbers
            # 
            for p in D[q]:
                D.setdefault(p + q, []).append(p)
            del D[q]
        
        q += 1

def green(str):
	return bcolors.OKGREEN + str.__str__() + bcolors.ENDC

def red(str):
	return bcolors.OKRED + str.__str__() + bcolors.ENDC
def yellow(str):
	return bcolors.OKYELLOW + str.__str__() + bcolors.ENDC

def main():
    for p in primes(1000):
		#print p, p%4
		if p % 4 == 1:
			print green(p)
		elif p %4 ==3 :
			print red(p)
		else:
			print yellow(p)

main()
