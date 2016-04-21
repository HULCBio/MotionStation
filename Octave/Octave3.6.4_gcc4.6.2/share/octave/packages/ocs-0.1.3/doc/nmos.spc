* A Simple MOSFET analog amplifier
* Input voltage sources
V1 Vgate 0 SIN(0.5 0.5 1 0.25 0)

* N-Mosfet
.MODEL mynmos NMOS( k=1e-4 Vth=0.1 rd=1e6)
M2 Vgate 0 Vdrain 0 mynmos

* Power supply
V3 3 0 1

* Resistors
R4 3 Vdrain 1e5
.END
