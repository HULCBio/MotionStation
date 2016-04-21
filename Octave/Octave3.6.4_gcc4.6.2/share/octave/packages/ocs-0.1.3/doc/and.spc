* AND (simple Algebraic MOS-FET model)

.MODEL mynmos NMOS(LEVEL=simple k=2.94e-05   Vth=0.08	rd=.957e7)
.MODEL mypmos PMOS( k=-2.94e-05   Vth=-0.08	rd=.957e7)

M1 Va 3  4        0 mynmos 
M2 Vb 0  3        0 mynmos 
* nside of the inverter
M3 4  0  Va_and_b 0 mynmos       

M4 Va Vdd 4        Vdd  mypmos
M5 Vb Vdd 4        Vdd  mypmos
 * pside of the inverter
M6 4  Vdd Va_and_b Vdd  mypmos  

V1  Va 0 SIN(0.5 0.5 1 0 0)
V2  Vb 0 SIN(0.5 0.5 2 0.25 0)
V3 Vdd 0 1

.END
