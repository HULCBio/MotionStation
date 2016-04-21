%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo on
%--------------------------------------------------------------------
%
%	tankdemo
%
%	A two tank system is used to illustrate the application
%	of D-K iteration and mu synthesis to a process control
%	problem.
%
%	The accompanying notes in the manual give a detailed
%	discussion on the development of the system model and
%	the set up of the design problem.
%
%-------------------------------------------------------------------

pause;	% push any key to continue

%	The system constants are defined

th = 1.0;		% hot water supply temp (tunits)
tc = 0.0;		% cold water supply temp (tunits)
A1 = 0.0256;		% area: tank 1
A2 = 0.0477;		% area: tank 2
h2 = 0.241;		% height of tank 2 (fixed by overflow)
fb = 3.28e-5;		% bias stream flow
tb = tc;		% bias stream temp (cold)
fs = 0.00028;		% flow scaling to get actuator between 0 and 1

%	Experimentally determined model constants for the
%	flow/height relationship:  h1 = alpha*f1 - beta;

alpha = 4876;
beta = 0.59;

pause;	% push any key to continue

%	We now set up the nominal models for the design.  This
%	is done as a function of an operating point to enable
%	different operating conditions to be studied easily.

%	Operating point:

h1ss = 0.75;		% h1 steady state value
t1ss = 0.75;		% t1 steady state value

pause;	% push any key to continue

%	Tank 1 nominal model:  the inputs are  [fh; fc]
%	and the outputs are [h1; t1].
%
%	Refer to the manual notes for the derivation of
%	this linearization.

A = [ -1/(A1*alpha),          0;
      (beta*t1ss)/(A1*h1ss),  -(h1ss+beta)/(alpha*A1*h1ss)];

B = [ 1/(A1*alpha),   1/(A1*alpha);
      th/A1,          tc/A1];

%	include the flow scale factors:
B = fs*B;

C = [ alpha,             0;
      -alpha*t1ss/h1ss,  1/h1ss];

tank1nom = pck(A,B,C);

%	The steady state hot and cold flows can also be calculated
%	We invert the nonlinear steady state relationship to do
%	this calculation.

f1ss = (h1ss+beta)/alpha;	% steady state flow tank 1 -> tank 2
fss = inv([th,tc;1,1])*[t1ss*f1ss;f1ss];
fhss = fss(1);
fcss = fss(2);			% these
clear fss


pause;	% push any key to continue

%	A nominal linearized model is created for Tank 2.

%	The steady state value of t2 is determined by
%	the differential equation derived in the manual
%	notes.  The inputs are [h1; t1] and the output is
%	t2.

t2ss = (f1ss*t1ss + fb*tb)/(f1ss + fb);	% steady state temp: tank 2

A = -(h1ss + beta + alpha*fb)/(A2*h2*alpha);
B = [ (t2ss+t1ss)/(alpha*A2*h2),  (h1ss + beta)/(alpha*A2*h2) ];
C = 1;
tank2nom = pck(A,B,C);

pause;	% push any key to continue

%	Models of the actuators and anti-aliasing filters
%	are now created.

%	We initially set up an actuator model with two
%	outputs (the actuated signal and its derivative).
%	The derivative output will be useful in penalizing
%	the actuation rate in the design problem.

act_BW = 20;		% actuator bandwidth (rad/sec)
int = nd2sys(1,[1,0]);	% a pure integrator

systemnames = 'int act_BW';
inputvar = '[cmd]';
outputvar = '[int; act_BW]';
input_to_int = '[act_BW]';
input_to_act_BW = '[cmd - int]';
sysoutname = 'actuator';
cleanupsysic = 'yes';
echo off; sysic; echo on

hot_act = actuator;
cold_act =actuator;

% 	Now do the anti-aliasing filters

fbw = 2.25;		% antialiasing filter cut-off (Hz)
filter = mfilter(fbw,4,'butterw');
h1F = filter;
t1F = filter;
t2F = filter;

pause;	% push any key to continue

%	A full tank 1 model is compared to experimental estimates
%	of the transfer functions.  The models for this
%	comparison are generated here.  Actuators and anti-aliasing
%	filters must be included.

h_act_nom = sel(hot_act,1,1);		% delete the derivative output
c_act_nom = sel(cold_act,1,1);
tank1model = mmult(daug(h1F,t1F),tank1nom,daug(h_act_nom,c_act_nom));

%	A frequency response is calculated in Hz and rad/sec.

Hz = logspace(-5,1,100);
frad = 2*pi*Hz;
tank1model_g = frsp(tank1model,frad);
tank1model_Hz = scliv(tank1model_g,1/(2*pi));

%	Look at the fh + fc --> h1 transfer function.
%	Simple manipulation shows that this is equal to:
%	[tank1model(1,1) + tank1model(1,2)]/2

tf = madd(sel(tank1model_Hz,1,1),sel(tank1model_Hz,1,2));
tf = mmult(tf,0.5);

subplot(2,1,1)
vplot('liv,lm',tf)
axis([1e-4,10,1e-5,10])
grid
xlabel('Frequency: Hertz')
ylabel('Magnitude')
title('Nominal transfer function: (fhc + fcc) -> h1')

subplot(2,1,2)
vplot('liv,p',tf)
axis([1e-4,10,-600,0])
grid
xlabel('Frequency: Hertz')
ylabel('Phase (degrees)')
title('Nominal transfer function: (fhc + fcc) -> h1')

pause;	% push any key to continue

%	We now look at the nominal t1 response.  Choosing
%	an input signal, u, and setting:
%
%		fhc = u,  fcc = -u,
%
%	Maintains the same level.  In this way we can
%	examine the t1/(fhc-fcc) transfer function.
%	This is compared to an experimental estimate of
%	the transfer function in the manual notes.

tf = msub(sel(tank1model_Hz,2,1),sel(tank1model_Hz,2,2));
tf = mmult(tf,0.5);

subplot(2,1,1)
vplot('liv,lm',tf)
axis([1e-4,10,1e-4,10])
grid
xlabel('Frequency: Hertz')
ylabel('Magnitude')
title('Nominal transfer function: (fhc - fcc) -> t1')

subplot(2,1,2)
vplot('liv,p',tf)
axis([1e-4,10,-450,0])
grid
xlabel('Frequency: Hertz')
ylabel('Phase (degrees)')
title('Nominal transfer function: (fhc - fcc) -> t1')

pause;	% push any key to continue

%	Now we set up the control design problem.  We are
%	interested in reference tracking for t1 and t2.
%	The controller will have measurements of t1 and t2
%	and the t1, t2 references signals.  We construct
%	the weighting to reflect that we will usually command
%	t2 such that t2-t1 is small.

%	The following weights are chosen (see the accompanying
%	notes in the manual).

Wh1 = madd(0.01,nd2sys([0.5,0],[0.25,1]));
Wt1 = madd(0.1,nd2sys([20*h1ss,0],[0.2,1]));
Wt2 = madd(0.1,nd2sys([100,0],[1,21]));

Wt1cmd = 0.1;		% t1 input command weight
Wtdiffcmd = 0.01;	% t2 - t1  input command weight

Wt1perf = nd2sys(100,[400,1]);	% t1 tracking error weight
Wt2perf = nd2sys(50,[800,1]);	% t2 tracking error weight

Wh1noise = 0.01;	% h1 noise weight
Wt1noise = 0.03;	% t1 noise weight
Wt2noise = 0.03;	% t2 noise weight

Whact =  0.01;		% hot actuator penalty
Wcact =  0.01;		% cold actuator penalty

Whrate = 50;		% hot actuator rate penalty
Wcrate = 50;		% cold actuator rate penalty

pause;	% push any key to continue

%	Now plot the perturbation weights.
%	Note that the h1 and t1 perturbations will
%	effectively occur at the input to the tank 2
%	nominal model.

Wh1_hz = frsp(Wh1,frad);
Wh1_hz = scliv(Wh1_hz,1/(2*pi));
Wt1_hz = frsp(Wt1,frad);
Wt1_hz = scliv(Wt1_hz,1/(2*pi));
Wt2_hz = frsp(Wt2,frad);
Wt2_hz = scliv(Wt2_hz,1/(2*pi));

subplot(1,1,1)
vplot('liv,lm',Wh1_hz,'-',Wt1_hz,'-.',Wt2_hz,'--')
axis([1e-5,10,1e-3,1000])
xlabel('Frequency: Hertz')
ylabel('Magnitude')
title('Perturbation Weights for the two tank design')
legend('Wh1','Wt1','Wt2')


pause;	% push any key to continue

%	Now plot the performance weights.

Wt1perf_hz = frsp(Wt1perf,frad);
Wt1perf_hz = scliv(Wt1perf_hz,1/(2*pi));
Wt2perf_hz = frsp(Wt2perf,frad);
Wt2perf_hz = scliv(Wt2perf_hz,1/(2*pi));
Wt1cmd_hz = frsp(Wt1cmd,frad);
Wt1cmd_hz = scliv(Wt1cmd_hz,1/(2*pi));
Wtdiffcmd_hz = frsp(Wtdiffcmd,frad);
Wtdiffcmd_hz = scliv(Wtdiffcmd_hz,1/(2*pi));

subplot(1,1,1)
vplot('liv,lm',Wt1perf_hz,'-',Wt2perf_hz,'-.',Wt1cmd_hz,'--',Wtdiffcmd_hz,':')
axis([1e-5,10,1e-3,1000])
xlabel('Frequency: Hertz')
ylabel('Magnitude')
title('Perturbation Weights for the two tank design')
legend('Wt1perf','Wt2perf','Wt1cmd','Wtdiffcmd')

pause;	% push any key to continue

%	The interconnection structure is created for
%	design purposes.

systemnames = 'tank1nom tank2nom hot_act cold_act t1F t2F';
systemnames = [systemnames,' Wh1 Wt1 Wt2 Wt1cmd Wtdiffcmd Whact Wcact'];
systemnames = [systemnames,' Whrate Wcrate'];
systemnames = [systemnames,' Wt1perf Wt2perf Wt1noise Wt2noise'];
inputvar = '[v1;v2;v3;t1cmd;tdiffcmd;t1noise;t2noise;fhc;fcc]';
outputvar = '[Wh1;Wt1;Wt2;Wt1perf;Wt2perf;Whact;Wcact;Whrate;Wcrate';
outputvar = [outputvar,'; Wt1cmd; Wt1cmd+Wtdiffcmd;'];
outputvar = [outputvar,' Wt1noise+t1F;  Wt2noise+t2F]'];
input_to_tank1nom = '[hot_act(1);cold_act(1)]';
input_to_tank2nom = '[v1+tank1nom(1);v2+tank1nom(2)]';
input_to_hot_act = '[fhc]';
input_to_cold_act = '[fcc]';
input_to_t1F = '[v2+tank1nom(2)]';
input_to_t2F = '[v3+tank2nom]';
input_to_Wh1 = '[tank1nom(1)]';
input_to_Wt1 = '[tank1nom(2)]';
input_to_Wt2 = '[tank2nom]';
input_to_Wt1cmd = '[t1cmd]';
input_to_Wtdiffcmd = '[tdiffcmd]';
input_to_Whact = '[hot_act(1)]';
input_to_Wcact = '[cold_act(1)]';
input_to_Whrate = '[hot_act(2)]';
input_to_Wcrate = '[cold_act(2)]';
input_to_Wt1perf = '[Wt1cmd - tank1nom(2) - v2]';
input_to_Wt2perf = '[Wtdiffcmd + Wt1cmd - tank2nom - v3]';
input_to_Wt1noise = '[t1noise]';
input_to_Wt2noise = '[t2noise]';
sysoutname = 'P';
cleanupsysic = 'yes';
echo off;sysic;echo on

disp('Interconnection structure: ')
minfo(P)

pause;	% push any key to continue

%	Now we do an initial Hinf design, using only the nominal
%	part of the problem.  Simulating this design is a reasonable
%	way of checking that we have set the nominal performance
%	weights at the right values.   Subsequenct D-K iterations
%	(on the full interconnection structure) will generally
%	trade off some of this performance for improved robustness.

nmeas = 4;		% number of measurements
nctrls = 2;		% number of controls
gmin = 0.5;		% minimum gamma value for bisection.
gmax = 10;		% maximum gamma value for bisection.
gtol = 0.05;		% relative tolerance on final gamma value

Pnom = sel(P,[4:13],[4:9]);	% nominal system

[k0,g0,gamma0] = hinfsyn(Pnom,nmeas,nctrls,gmin,gmax,gtol);

pause;	% push any key to continue

%	Now we look at a the frequency response of the controller
%	and simulate its performance for a particular input.

k0_g = frsp(k0,frad);
k0_hz = scliv(k0_g,1/(2*pi));

subplot(1,1,1)
vplot('liv,lm',k0_hz)
title('Nominal controller: k0')
ylabel('Magnitude')
xlabel('Frequency: Hertz')
grid

pause;	% push any key to continue

%	An interconnection structure is created for the simulation.
%	The inputs are:  [ t1ref; t2ref; t1noise; t2noise; fhc; fcc ]
%	and the outputs are: [h1; t1; t2; fhc; fcc; t1ref; t2ref; t1; t2].
%	Starp() is used to form the final closed-loop to facilitate
%	the simulation of other controllers.

systemnames = 'tank1nom tank2nom hot_act cold_act t1F t2F';
inputvar = '[t1ref; t2ref; t1noise; t2noise; fhc; fcc]';
outputvar = '[ tank1nom; tank2nom; fhc; fcc; t1ref; t2ref; ';
outputvar = [outputvar 't1F+t1noise; t2F+t2noise]'];
input_to_tank1nom = '[hot_act(1); cold_act(1)]';
input_to_tank2nom = '[tank1nom]';
input_to_hot_act = '[fhc]';
input_to_cold_act = '[fcc]';
input_to_t1F = '[tank1nom(2)]';
input_to_t2F = '[tank2nom]';
sysoutname = 'simlft';
cleanupsysic = 'yes';
echo off; sysic; echo on

sim_k0 = starp(simlft,k0);

pause;	% push any key to continue

%	step up the input as a step at 80 seconds

u0 = zeros(4,1);
uend = [ -0.18;		% t1 reference command
        -0.20;           % t2 reference command
         0;		% t1 noise
         0];		% t2 noise
u = vpck([u0;u0;uend],[0;80;100]);
clear u0 u80
u = vinterp(u,1,800,1);		% make it into a ramp.

y = trsp(sim_k0,u,800,1);

%	select the outputs and add them to their steady state values

h1 = madd(h1ss,sel(y,1,1));
t1 = madd(t1ss,sel(y,2,1));
t2 = madd(t2ss,sel(y,3,1));
fhc = madd(fhss/fs,sel(y,4,1));		% note scaling to actuator
fcc = madd(fcss/fs,sel(y,5,1));		% limits (0<= fhc <= 1) etc.

vplot(h1,'--',t1,'-',t2,'-.')
xlabel('Time: seconds')
ylabel('Measurements')
title('Design k0,  step response')
legend('h1','t1','t2');
grid

pause;	% push any key to continue

vplot(fhc,'-',fcc,'-.')
xlabel('Time: seconds')
ylabel('Actuators')
title('Design k0,  step response')
legend('fhc','fcc');
grid

pause;	% push any key to continue

%	Now we set up a robust design problem.  The full
%	interconnection structure (including perturbation
%	inputs and outputs) is used.

%	We will perform three D-K iterations "by hand".  See
%	the manual for details on how this procedure can be
%	automated using the autodkit function.

%	In each of the D scale fits we select a 2nd order
%	fit, for each of the D-scales.  Other selections
%	are possible and will lead to slightly different
%	controllers.

%	The block structure is defined:

blk = [1,1;		% h1 perturbation
       1,1;		% t1 perturbation
       1,1;		% t2 perturbation
       4,6];		% performance block

%	Do an Hinf design.

[k1,g1,gamma1] = hinfsyn(P,nmeas,nctrls,gmin,gmax,gtol);
g1_g = frsp(g1,frad);
g1_hz = scliv(g1_g,1/(2*pi));

% 	And now a mu analysis.

[bnds1,rowd1,sens1] = mu(g1_hz,blk);	% robust performance

rsbnds1 = mu(sel(g1_hz,[1:3],[1:3]),blk(1:3,:));
nomp = vnorm(sel(g1_hz,[4:9],[4:7]),2);

%	Only the upper bounds are plotted.

vplot('liv,m',sel(bnds1,1,1),'-',sel(rsbnds1,1,1),'-.',nomp,'--')
title('mu analysis: controller k1')
xlabel('Frequency: Hertz')
legend('rob perf','rob stab','nom perf')
grid

pause;	% push any key to continue

%	Now we fit D-scales and perform a D-K iteration

[d1l,d1r] = musynfit('first',rowd1,sens1,blk,nmeas,nctrls,g1_hz,bnds1);

P2 = mmult(d1l,P,minv(d1r));
[k2,g2,gamma2] = hinfsyn(P2,nmeas,nctrls,gmin,gmax,gtol);

g2_g = frsp(g2,frad);
g2_hz = scliv(g2_g,1/(2*pi));

% 	And now a mu analysis.

[bnds2,rowd2,sens2] = mu(g2_hz,blk);	% robust performance

vplot('liv,m',sel(bnds2,1,1),'-',sel(bnds1,1,1),'-.')
title('mu comparison')
xlabel('Frequency: Hertz')
legend('controller: k2','controller: k1')
grid

pause;	% push any key to continue

%	Continue with the mu analysis.

rsbnds2 = mu(sel(g2_hz,[1:3],[1:3]),blk(1:3,:));
nomp = vnorm(sel(g2_hz,[4:9],[4:7]),2);

%	Only the upper bounds are plotted.

vplot('liv,m',sel(bnds2,1,1),'-',sel(rsbnds2,1,1),'-.',nomp,'--')
title('mu analysis: controller k2')
xlabel('Frequency: Hertz')
legend('rob perf','rob stab','nom perf')
grid

pause;	% push any key to continue

%	Another D scale fit and K iteration

[d2l,d2r] = musynfit(d1l,rowd2,sens2,blk,nmeas,nctrls,g2_hz,bnds2);

P3 = mmult(d2l,P,minv(d2r));
[k3,g3,gamma3] = hinfsyn(P3,nmeas,nctrls,gmin,gmax,gtol);

g3_g = frsp(g3,frad);
g3_hz = scliv(g3_g,1/(2*pi));

% 	And now a mu analysis.

[bnds3,rowd3,sens3] = mu(g3_hz,blk);	% robust performance

vplot('liv,m',sel(bnds3,1,1),'-',sel(bnds2,1,1),'-.',sel(bnds1,1,1),'--')
title('mu comparison')
xlabel('Frequency: Hertz')
legend('controller: k3','controller: k2','controller: k1')
grid

pause;	% push any key to continue

%	Continue with the mu analysis.

rsbnds3 = mu(sel(g3_hz,[1:3],[1:3]),blk(1:3,:));
nomp = vnorm(sel(g3_hz,[4:9],[4:7]),2);

%	Only the upper bounds are plotted.

vplot('liv,m',sel(bnds3,1,1),'-',sel(rsbnds3,1,1),'-.',nomp,'--')
title('mu analysis: controller kmu')
xlabel('Frequency: Hertz')
legend('rob perf','rob stab','nom perf')
grid

pause;	% push any key to continue

%	At this point we are finished with the design.
%	Further interations may gain some additional robust
%	performance, but the current controller will serve
%	our purposes.  Now let's see what it looks like.

%	Look at the frequency response of the final controller.

k3_g = frsp(k3,frad);
k3_hz = scliv(k3_g,1/(2*pi));

subplot(1,1,1)
vplot('liv,lm',k3_hz)
axis([1e-5,10,1e-5,10])
title('Controller: kmu')
ylabel('Magnitude')
xlabel('Frequency: Hertz')
grid

subplot(1,1,1)
vplot('liv,p',k3_hz)
title('Controller: kmu')
ylabel('Phase (degrees)')
xlabel('Frequency: Hertz')
grid

pause;	% push any key to continue

%	Now we look at a simulation of the final controller.

sim_k3 = starp(simlft,k3);

y = trsp(sim_k3,u,800,1);

%	select the outputs and add them to their steady state values

h1 = madd(h1ss,sel(y,1,1));
t1 = madd(t1ss,sel(y,2,1));
t2 = madd(t2ss,sel(y,3,1));
fhc = madd(fhss/fs,sel(y,4,1));		% note scaling to actuator
fcc = madd(fcss/fs,sel(y,5,1));		% limits (0<= fhc <= 1) etc.

vplot(h1,'--',t1,'-',t2,'-.')
xlabel('Time: seconds')
ylabel('Measurements')
title('Design kmu,  step response')
legend('h1','t1','t2');
grid

pause;	% push any key to continue

vplot(fhc,'-',fcc,'-.')
xlabel('Time: seconds')
ylabel('Actuators')
title('Design kmu,  step response')
legend('fhc','fcc');
grid

pause;	% push any key to continue

%	The elements of the mu upper bound matrix
%	are studied to determine the factors that are
%	limiting robust performance.

%	We first reconstruct the D scalings and then
%	the upper bound matrix (DMDinv).

[d3l_hz,d3r_hz] = unwrapd(rowd3,blk);
mu3upper = mmult(d3l_hz,g3_hz,minv(d3r_hz));

%	Large elements in this matrix indicate what is
%	limiting the achievable robust performance.

pause;	% push any key to continue

%	First we look at the nominal performance issues.
%	This can be studied at several levels of detail.
%	We start with a coarse level by selecting blocks
%	rather than individual elements.

cmds2errors = sel(mu3upper,[4,5],[4,5]);	% commands -> errors
cmds2act = sel(mu3upper,[6,7],[4,5]);		% commands -> act.
cmds2rate = sel(mu3upper,[8,9],[4,5]);		% commands -> rates

n2errors = sel(mu3upper,[4,5],[6,7]);		% noise -> errors
n2act = sel(mu3upper,[6,7],[6,7]);		% noise -> act.
n2rate = sel(mu3upper,[8,9],[6,7]);		% noise -> rates

%	These are compared to mu and the full nominal
%	performance bound (i.e. svd of all performance inputs to
%	all performance outputs).

subplot(3,1,1)
vplot('liv,m',vnorm(cmds2errors,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: temp cmds -> errors')
xlabel('Frequency: Hertz')
legend('cmds -> errors','rob perf','nom perf')

subplot(3,1,2)
vplot('liv,m',vnorm(cmds2act,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: temp cmds -> actuator')
xlabel('Frequency: Hertz')
legend('cmds -> actuator','rob perf','nom perf')

subplot(3,1,3)
vplot('liv,m',vnorm(cmds2rate,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: temp cmds -> act rate')
xlabel('Frequency: Hertz')
legend('cmds -> act rate','rob perf','nom perf')

%	The following is for generating the plots only
h = get(gcf);
set(h,'PaperPosition',[0.25,1.5,8,8]);

pause;	% push any key to continue

%	Now look at the noise input limitations

subplot(3,1,1)
vplot('liv,m',vnorm(n2errors,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: noise -> errors')
xlabel('Frequency: Hertz')
legend('noise -> errors','rob perf','nom perf')

subplot(3,1,2)
vplot('liv,m',vnorm(n2act,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: noise -> actuator')
xlabel('Frequency: Hertz')
legend('noise -> actuator','rob perf','nom perf')

subplot(3,1,3)
vplot('liv,m',vnorm(n2rate,2),'-',sel(bnds3,1,1),'-.',nomp,'--')
title('DMDinv analysis for kmu: noise -> act rate')
xlabel('Frequency: Hertz')
legend('noise -> act rate','rob perf','nom perf')

pause;	% push any key to continue

%	The robust stability issues are examined.  We look
%	at a single perturbation block at a time.  This
%	neglects the effect of simultaneous perturbations
%	but will still give an idea of which uncertainties
%	are the most critical for robust stability.

h1pert = sel(mu3upper,[1],[1]);		% h1 perturbation
t1pert = sel(mu3upper,[2],[2]);		% t1 perturbation
t2pert = sel(mu3upper,[3],[3]);		% t2 perturbation

subplot(3,1,1)
vplot('liv,m',vnorm(h1pert,2),'-',sel(bnds3,1,1),'-.',sel(rsbnds3,1,1),'--')
title('DMDinv analysis for kmu: h1 perturbation')
xlabel('Frequency: Hertz')
legend('h1 pert tf','rob perf','rob stab')

subplot(3,1,2)
vplot('liv,m',vnorm(t1pert,2),'-',sel(bnds3,1,1),'-.',sel(rsbnds3,1,1),'--')
title('DMDinv analysis for kmu: t1 perturbation')
xlabel('Frequency: Hertz')
legend('t1 perf tf','rob perf','rob stab')

subplot(3,1,3)
vplot('liv,m',vnorm(t2pert,2),'-',sel(bnds3,1,1),'-.',sel(rsbnds3,1,1),'--')
title('DMDinv analysis for kmu: t2 perturbation')
xlabel('Frequency: Hertz')
legend('t2 pert tf','rob perf','rob stab')

pause;	% push any key to continue


echo off
%---------------------------------------------------------------------