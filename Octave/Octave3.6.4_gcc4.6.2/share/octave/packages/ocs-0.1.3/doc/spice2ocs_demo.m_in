clear all;
clc;

## Circuit

cir = menu ("Chose the circuit to analyze:",\
	    "AND (Simple algebraic MOS-FET model)",\
	    "AND (Simple MOS-FET model with parasitic capacitances)",\
	    "Diode clamper (Simple exponential diode model)",\
	    "CMOS-inverter circuit (Simple algebraic MOS-FET model)",\
	    "n-MOS analog amplifier (Simple algebraic MOS-FET model)",\
	    "Linear RC circuit",\
	    "Diode bridge rectifier");

switch cir
  case 1
    outstruct = prs_spice ("and");
    x         = [.5 .5 .33 .66 .5 1 0 0 1 ]';
    t         = linspace (0,.5,100);
    pltvars   = {"Va","Vb","Va_and_b"};
    dmp       = .2;
    tol       = 1e-15;
    maxit     = 100;
  case 2
    outstruct = prs_spice ("and2")
    x         = [.8;.8;0.00232;0.00465;.8;
		 .8;0.00232;0.00465;0.00000;
		 0.0;0.0;0.0;0.00232;0.0;
		 0.0;0.0;0.0;1.0;0.0;-0.0;
		 0.0;1.0;0.00465;0.0;0.0;
		 -0.0;1.0;0.00465;0.0;
		 0.0;0.0;1.0;1.0;0.0;0.0;0.0;
		 0.0;0.0;0.0];
    t       = linspace (.25e-6,.5e-6,100);
    dmp     = .1;
    pltvars = {"Va","Vb","Va_and_b"};
    tol     = 1e-15;
    maxit   = 100;
  case 3
    outstruct = prs_spice ("diode");
    x   = [0 0 0 0 0]';
    t   = linspace (0, 3e-10, 200);
    dmp = .1;
    pltvars = {"Vin", "Vout","V2"};
    tol   = 1e-15;
    maxit = 100;
  case 4
    outstruct = prs_spice ("inverter");
    x   = [.5  .5   1   0   0]';
    t   = linspace (0,1,100);
    dmp = .1;
    pltvars={"Vgate","Vdrain"};
    tol   = 1e-15;
    maxit = 100;
  case 5
    outstruct = prs_spice ("nmos");
    x         = [1 .03 1 0 0]';
    t         = linspace (0,1,50);
    dmp       = .1;
    pltvars   = {"Vgate","Vdrain"};
    tol   = 1e-15;
    maxit = 100;
  case 6
    outstruct = prs_spice ("rcs");
    x         = [0 0 0 0]';
    t         = linspace (0,2e-5,100);
    dmp       = 1;
    pltvars   = {"Vout"};
    tol   = 1e-15;
    maxit = 100;
  case 7
    outstruct = prs_spice ("rect");
    x         = [0 0 0 0 ]';
    t         = linspace (0, 3e-10, 60);
    dmp       = .1;
    pltvars   = {"Vin","Voutlow","Vouthigh"};
    tol   = 1e-15;
    maxit = 100;
  otherwise
    error ("unknown circuit");
endswitch

#clc;

## DAE solver
slv = menu("Chose the solver to use:",
	   "BWEULER", # 1
	   "DASPK",   # 2
	   "THETA",   # 3
	   "ODERS",   # 4
	   "ODESX",   # 5
	   "ODE2R",   # 6
	   "ODE5R"    # 7
	   );

out   = zeros(rows(x),columns(t));

switch slv
  case 1
    out = tst_backward_euler (outstruct,x,t,tol,maxit,pltvars);
  case 2
    out = tst_daspk (outstruct,x,t,tol,maxit,pltvars);
  case 3
    out = tst_theta_method (outstruct,x,t,tol,maxit,.5,pltvars,[0 0]);
  case 4
    out = tst_odepkg (outstruct,x,t,tol,maxit,pltvars,"oders",[0,1]);
  case 5
    out = tst_odepkg (outstruct,x,t,tol,maxit,pltvars,"odesx",[0,1]);
  case 6
    out = tst_odepkg (outstruct,x,t,tol,maxit,pltvars,"ode2r",[0,1]);
  case 7
    out = tst_odepkg (outstruct,x,t,tol,maxit,pltvars,"ode5r",[0,1])
  otherwise
    error ("unknown solver");
endswitch

utl_plot_by_name (t,out,outstruct,pltvars);
axis ("tight");
