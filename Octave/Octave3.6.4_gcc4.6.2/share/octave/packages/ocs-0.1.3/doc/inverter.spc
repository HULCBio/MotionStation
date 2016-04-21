* A Simple MOSFET inverter
* Input voltage sources
V1 Vgate 0 SIN(0.5 0.5 1 0 0)

* P-Mosfet
.MODEL mypmos PMOS( k=-1e-4 Vth=-0.1 rd=1e6)
M2 Vgate 3 Vdrain 3 mypmos

* N-Mosfet
.MODEL mynmos NMOS( k=1e-4 Vth=0.1 rd=1e6)
M3 Vgate 0 Vdrain 0 mynmos

* Power supply
V4 3 0 1

.END
