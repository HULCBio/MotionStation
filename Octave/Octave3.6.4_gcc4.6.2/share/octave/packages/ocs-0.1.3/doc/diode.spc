* diode clamper

V1 Vin 0 SIN(0 5 10G 0 0)
R2 Vin V2 1k 
R3 V2 0 1e3
C4 V2 Vout 1p
D5 Vout 0 Is=1e-9 Vth=75e-3
D6 0 Vout Is=1e-9 Vth=75e-3

.END
