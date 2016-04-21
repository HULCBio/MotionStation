* A Simple 4 Diodes Rectifier circuit
* Input Voltage Source
* Mvoltagesources sinwave 2 4
* 1 4
* Ampl      f           delay     shift
* 5         1e10        0.0       0.0
* 1 0

V1 Vin 0 SIN(0 5 10G 0 0)
 
* Diodes
* Mdiode simple 2 1
* 4 1
* Is
* 1e-9
* 1e-9
* 1e-9
* 1e-9
* 2 1
* 1 3
* 0 3
* 2 0

D2 Voutlow Vin Is=1n
* Vth=0.027
D3 Vin     Vouthigh Is=1n Vth=0.027
D4 0       Vouthigh Is=1n Vth=0.027
D5 Voutlow 0        Is=1n Vth=0.027

*Output Resistive Load
*Mresistors LIN 2 1
*1 1
*R
*1e6
*3 2

R6 Vouthigh Voutlow 1MEG

.END