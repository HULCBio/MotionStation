* A Simple CMOS AND GATE
* models declarations
.MODEL mynmos NMOS(LEVEL=lincap k=4.354e-5   Vth=0.7   rd=1e6   Cb=13e-14)
.MODEL mypmos PMOS(LEVEL=lincap k=-4.354e-5  Vth=-0.7  rd=1e7  Cb=13e-14)

* N-Mosfets
M1 Va 3 4        0 mynmos
M2 Vb 0 3        0 mynmos
M3 4  0 Va_and_b 0 mynmos

* P-Mosfets
M4 Va Vdd 4        Vdd mypmos
M5 Vb Vdd 4        Vdd mypmos
M6 4  Vdd Va_and_b Vdd mypmos

* Input voltage sources
V2 Vb 0 SIN(0.8 -0.8 4MEG -0.0625u 0)

* Power supply
V1 Va  0 1.6
V3 Vdd 0 1.6

.END
