import numpy as np
from matplotlib import pyplot as pl

 
i1 = 0    # start setpoint bits
i2 = 5242    # end setpoint bits
R = 52428.800781 # ramp rate bits/s  
fs = 10000   # DAC update rate

 
a = 0.1      # fraction of total ramp used by beginning and end curved parts

D = np.abs(i2 - i1) / R  # ramp duration seconds

#if D < 2:
#    D = 2

D0 = (1 - 2*a) * D         # duration of linear part of ramp
L = int(D0 * fs)      # number of points in linear part of ramp
M = int(a * D * fs)         # number of points in beginning/end curved parts

 
Y = np.zeros(L + 2*M)

 
print("i1 = %3.5f" % i1)
print("i2 = %3.5f" % i2)
print("ramp rate     = %3.2f bits/s" % R)
print("ramp duration = %3.2f s" % D)
print("linear numpts = %d" % L)
print("curved numpts = %d" % M) 
print("Total numpts  = %d" % (L + 2*M))


sp0 = i1

#dy = (i2 - i1) / L / (1 + a)
dy = (i2 - i1) / (L + M)

# Divide once before the loop
dy_per_curve_pt = dy / M

print("dy = %f" % dy)
print("dy_per_curve_pt = %f" % dy_per_curve_pt)

 
i = 0

while i < L + 2*M:

    if i < M:
        dy0 = dy_per_curve_pt * i
        sp1 = sp0 + dy0
        sp0 = sp1
        print("i = %d, dy = %f  sp1 = %f" % (i, dy0, sp1)) 
        Y[i] = sp1   

    elif i < L + M:
        sp1 = sp0 + dy
        sp0 = sp1
        print("i = %d, dy = %f  sp1 = %f" % (i, dy, sp1)) 
        Y[i] = sp1

    else:
        dy0 = dy_per_curve_pt * (L + 2*M - i)
        sp1 = sp0 + dy0
        sp0 = sp1
        print("i = %d, dy = %f  sp1 = %f" % (i, dy0, sp1)) 
        Y[i] = sp1
       
    i += 1  

print("Final Value: %f" % sp1) 
pl.plot(Y)
pl.grid(True)
pl.show()
