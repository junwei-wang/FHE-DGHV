"""
" Filename:      somewhat-fhe-with-compressed-keys.sage
" Author:        Junwei Wang(wakemecn@gmail.com)
" Last Modified: 2013-11-14 21:34
" Description:   Implementation of Elliptic Curve
"""

# TODO: make sure the value of parameters 
# use TOY parameters settings to test
var_lambda = 42 # TODO
rho = 27
eta = 1026
gamma = 150000

tau = 10000
alpha = 1
rho1 = rho + alpha

def keyGen():
    " keyGen "
    p = random_prime(2^(eta+1), proof=False, lbound=2^eta)

    init_val = 0
    se = initial_seed()
    set_random_seed(se)
    list_chi = [ZZ.random_element(2^gamma) for i in range(tau)]
    list_xi = [ZZ.random_element((2^(var_lambda+eta))//p) for i in range(tau)]
    list_r = [ZZ.random_element(-2^rho+1, 2^rho) for i in range(tau)]
    list_delta = [init_val for i in range(tau)] 
    for i in range(tau):
        list_delta[i] = (list_chi[i] % p) + list_xi[i] * p - list_r[i]
 
    q0 = ZZ.random_element(2^gamma // p)
    x0 = q0 * p

    pk = [se, x0, list_delta]
    sk = p
    
    return pk, sk
    
        
def encrypt(pk, m):
    " encrypt "
    c = m

    x0 = pk[1]
    se = pk[0]
    set_random_seed(se)
    list_chi = [ZZ.random_element(2^gamma) for i in range(tau)]
    for i in range(tau):
        b_i = ZZ.random_element(2^alpha) # TODO
        x_i = list_chi[i] - pk[2][i]
        c = (c + 2 * b_i * x_i) % x0

    r = ZZ.random_element(-2^rho1+1, 2^rho1)
    c = (c + 2 * r) % x0

    #print c
    return c

"""
def evaluate(pk, c, c_list):
"""

def decrypt(sk, c):
    return (c % sk) % 2 

def testSomewhatFHE():
    pk, sk = keyGen()

    m0 = 0
    c0 = encrypt(pk, m0)
    m0_dec = decrypt(sk, c0)

    m1 = 1
    c1 = encrypt(pk, m1)
    m1_dec = decrypt(sk, c1)

    print "m0_dec == m0:", m0_dec == m0
    print "m1_dec == m1:", m1_dec == m1

    print "dec(enc(0) + enc(0)) =", decrypt(sk, c0 + c0)
    print "dec(enc(0) + enc(1)) =", decrypt(sk, c0 + c1)
    print "dec(enc(1) + enc(0)) =", decrypt(sk, c1 + c0)
    print "dec(enc(1) + enc(1)) =", decrypt(sk, c1 + c1)

    print "dec(enc(0) * enc(0)) =", decrypt(sk, c0 * c0)
    print "dec(enc(0) * enc(1)) =", decrypt(sk, c0 * c1)
    print "dec(enc(1) * enc(0)) =", decrypt(sk, c1 * c0)
    print "dec(enc(1) * enc(1)) =", decrypt(sk, c1 * c1)

    print "dec(enc(1) * enc(1)) + enc(0) * (enc(1) + enc(1)) =",\
       decrypt(sk, c1 * c1 + c0 * (c1 + c1))
    print "dec(enc(0) * enc(1)) + enc(0) * (enc(1) + enc(1)) =",\
       decrypt(sk, c0 * c1 + c0 * (c1 + c1))
    print "dec((enc(0) * enc(1) + enc(1) + enc(0)) * enc(1) * enc(0) * ",\
       "(enc(1) + enc(1))) =",\
       decrypt(sk, (c0 * c1 + c1 + c0) * c1 * c0 * (c1 + c1))
