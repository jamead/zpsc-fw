import numpy as np
from matplotlib import pyplot as pl

 
i1 = 0    # start setpoint (bits)
i2 = 5242 # end setpoint (bits)
R = 52428  # ramp rate bits/s  
fs = 10000 # DAC update rate

 
a = 0.1              # fraction of total ramp used by beginning and end curved parts
D = np.abs(i2-i1)/R  # ramp duration (s)
D0 = (1-2*a)*D       # of pts of linear part of ramp
D1 = a*D0            # of pts of curved part of ramp

L = int(D0*fs)       # number of points in linear part of ramp
M = int(D1*fs)       # of points in beginning and end curved parts of ramp

 
Y = np.zeros(L+2*M)

 
print("i1 = %3.5f" % i1)
print("i2 = %3.5f" % i2)
print("ramp rate     = %3.2f bits/s" % R)
print("linear part   = %3.2f s" % D0)
print("curved part   = %3.2f s" % D1)
print("ramp duration = %3.2f s" % D)
print("linear numpts = %3.2f " % L)
print("curved numpts = %3.2f " % M) 
print("Total numpts  = %3.2f" % (L+2*M))


sp0 = i1
dy = (i2-i1)/L/(1+a)
print("dy = %f" % dy)

 
i=0
while i < L+2*M:
    if i < M:
       dy0 = dy*float(i/M)
       sp1 = sp0 + dy0
       sp0 = sp1
       print("i = %d, dy = %f  sp1 = %f" % (i, dy0,sp1)) 
       Y[i] = sp1   

    if i >= M and i < L+M:
       sp1 = sp0 + dy
       sp0 = sp1
       print("i = %d, dy = %f  sp1 = %f" % (i, dy,sp1)) 
       Y[i] = sp1

    if i >= L+M:
       dy0 = dy*float((L+M+M-i)/M)
       sp1 = sp0 + dy0
       sp0 = sp1
       print("i = %d, dy = %f  sp1 = %f" % (i, dy0,sp1)) 
       Y[i] = sp1
       
  
    i+=1  

 
#print(Y[M])   
pl.plot(Y)
pl.grid(True)
pl.show()
