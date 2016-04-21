*% 0.1b1
*% Trivial Rc circuit
*% step input voltage
*% to test decay time
*%%%%%%%%%%%%%%%%%%
*% Power supply
*%%%%%%%%%%%%%%%%%%
*Mvoltagesources step 2 3
*1 3
*low high tstep
*0   1    1e-5
*1 0
*END

V1 Vin 0 PULSE(0 1 0 1e-8 1e-8 1e-5 2e-5)

*%%%%%%%%%%%%%%%%%%
*% Resistor
*%%%%%%%%%%%%%%%%%%
*Mresistors LIN 2 1
*1 1
*R
*1e6
*1 2

R2 Vin Vout 1MEG

*%%%%%%%%%%%%%%%%%%
*% Capacitors
*%%%%%%%%%%%%%%%%%%
*Mcapacitors LIN 2 1
*1 1
*C
*1e-12
*2 0
*END
C3 Vout 0 1P

.END
