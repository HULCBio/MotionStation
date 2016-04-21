function [A11,A12,A13,A14,A15,A16,A21,A22,A23,A24,A25,A26,A31,A32,A33,A34,...
          A35,A36,A41,A42,A43,A44,A45,A46,A51,A52,A53,A54,A55,A56,A61,A62,...
          A63,A64,A65,A66,A67,A81,A82,A92,g1,g2,g4,g9,u01,u02,Re,Le,Wr,...
          gref,Pmf ] = power_regulset(Vinf,mac,deltadeg)

% synchronous machine parameters (p.u)

%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

mv=get_param(mac,'MaskValues');

nom=eval(mv{4});			% nominal parameters
sta=eval(mv{5});		% stator parameters
Rs=sta(1); Ll=sta(2); Lmd=sta(3); Lmq=sta(4);
fld=eval(mv{6});		% field parameters
Rfd=fld(1); Llfd=fld(2);
dam=eval(mv{8});		% damper parameters
Rkd=dam(1); Llkd=dam(2); Rkq=dam(3); Llkq=dam(4);
mec=eval(mv{9});		% mechanical parameters
H=mec(1); F=mec(2);
ini=eval(mv{10}); th_init=ini(2);

Lfd=Llfd+Lmd;
Ld=Ll+Lmd;
Lq=Ll+Lmq;
Lkd=Llkd+Lmd;
Lkq=Llkq+Lmq;

% Base and nominal quantities
Pb=nom(1);		% base power
Vn=nom(2);		% nominal voltage
Wr=nom(3)*2*pi;		% nominal elec. ang. speed
Vb=Vn*sqrt(2/3);	% base voltage
Zb=Vn^2/Pb;		% base impedance
Lb=Zb/Wr;		% base reactance

% tension du bus infini(p.u):
K=Vinf;
a=pi/2;

% parametres de la turbine et du servomoteur:
turbine=gcb;
mv=get_param(turbine,'MaskValues');
svm=eval(mv{5});		% servo-motor parameters
Tg=1/svm(1);
gat=eval(mv{6});		% gate limit parameters
gmin=gat(1); gmax=gat(2); At=1/(gmax-gmin);
Tw=eval(mv{7});		% water time constant

G0=0.94;

% Line inductance and resistance
mv = get_param([gcs,'/Line/R1'],'MaskValues');
Re=eval(mv{1})/Zb;
mv = get_param([gcs,'/Line/RL1'],'MaskValues');
Le=eval(mv{2})/Lb;

% constantes du modele:

A11=-(Lfd*Lkd-Lmd^2)*(Rs+Re)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A12=-(Lmd*Lkd-Lmd^2)*Rfd*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A13=(Lq+Le)*(Lfd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A14=-Rkd*(Lfd*Lmd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A15=-Lmq*(Lfd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A16=-K*(Lfd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
g1=(Lmd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);


A21=-(Lmd*Lkd-Lmd^2)*(Rs+Re)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A22=-Rfd*((Ld+Le)*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A23=(Lmd*Lkd-Lmd^2)*Wr*(Lq+Le)/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A24=((Le+Ld)*Lmd-Lmd^2)*Rkd*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A25=-Lmq*(Lmd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A26=-K*(Lmd*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
g2=((Ld+Le)*Lkd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);


A31=-(Ld+Le)*Lkq*Wr/((Le+Lq)*Lkq-Lmq^2);
A32= Lkq*Lmd*Wr/((Le+Lq)*Lkq-Lmq^2);
A33=-(Rs+Re)*Lkq*Wr/((Le+Lq)*Lkq-Lmq^2);
A34=Lkq*Lmd*Wr/((Le+Lq)*Lkq-Lmq^2);
A35=-Lmq*Rkq*Wr/((Le+Lq)*Lkq-Lmq^2);
A36=-K*Lkq*Wr/((Le+Lq)*Lkq-Lmq^2);

A41=-(Rs+Re)*(Lmd*Lfd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A42=Rfd*((Ld+Le)*Lmd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A43=(Le+Lq)*(Lmd*Lfd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A44=-Rkd*(Lfd*(Ld+Le)-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A45=-Lmq*(Lmd*Lfd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
A46=-K*(Lmd*Lfd-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);
g4=-(Lmd*(Le+Ld)-Lmd^2)*Wr/((Le+Ld)*Lfd*Lkd-Lmd^2*(Ld+Le+Lkd+Lfd)+2*Lmd^3);

A51=-Lmq*(Le+Ld)*Wr/((Le+Lq)*Lkq-Lmq^2);
A52=Lmq*Lmd*Wr/((Le+Lq)*Lkq-Lmq^2);
A53=-(Rs+Re)*Lmq*Wr/((Le+Lq)*Lkq-Lmq^2);
A54=Lmd*Lmq*Wr/((Le+Lq)*Lkq-Lmq^2);
A55=-(Lq+Le)*Rkq*Wr/((Le+Lq)*Lkq-Lmq^2);
A56=-K*Lmq*Wr/((Le+Lq)*Lkq-Lmq^2);

A61=-(Lq-Ld)/(2*H);
A62=-Lmd/(2*H);
A63=-Lmd/(2*H);
A64=Lmq/(2*H);
A65=-F/(2*H);
A66=3/(2*H);
A67=-2*At/(2*H);

A81=-2/(Tw*G0);
A82=2*At/(Tw*G0);

A92=-1/Tg;
g9=1/Tg;

% valeurs initiales:
x07=th_init*pi/180;
u01=6.8683e-4;
A=[ A11,A12,A13,A14,A15
    A21,A22,A23,A24,A25
    A31,A32,A33,A34,A35
    A41,A42,A43,A44,A45
    A51,A52,A53,A54,A55];
B=[ -A16*cos(-x07+a)-g1*u01
    -A26*cos(-x07+a)-g2*u01
    -A36*sin(-x07+a)
    -A46*cos(-x07+a)-g4*u01
    -A56*sin(-x07+a)];
x0=inv(A)*B;
x01=x0(1);
x02=x0(2);
x03=x0(3);
x04=x0(4);
x05=x0(5);
x06=1;
Te0=(A61*x01*x03+A62*x02*x03+A63*x03*x04+A64*x01*x05)*2*H;
Pm0=-Te0;
u02=Pm0;

[gref,Pmf]=power_reguldelta(deltadeg);
