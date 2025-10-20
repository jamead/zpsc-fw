import math

N = 2000
period = 50 
amplitude = 1000
offset = 500

with open("oscillation_det_tb.txt", "w") as f:
    for n in range(N):
        value = offset + amplitude * math.sin(2 * math.pi * (n % period) / period)
        f.write(f"{int(round(value))}\n")

