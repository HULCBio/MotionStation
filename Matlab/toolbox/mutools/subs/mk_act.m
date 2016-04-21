%-------------------------- mk_act --------------------%
%
%  This makes up the 2 actuator models as specified in
%    the handout.  The actuator models each have 1 input
%    and 3 outputs.  They are listed below:
%
%
%    ACTRUD:  4 states, 3 outputs, 1 input
%	     OUTPUTS:		      INPUTS:
%		    1) position		1) rudder_cmd
%		    2) rate
%		    3) acceleration
%
%    ACTELE:  4 states, 3 outputs, 1 input
%	     OUTPUTS:		      INPUTS:
%		    1) position	        1) elevon_cmd
%		    2) rate
%		    3) acceleration

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

wrud = 21.0;
zetarud = 0.75;
wele = 14.0;
zetaele = 0.72;

wdel = 173.0;
zetadel = 0.866;
delaytf = nd2sys([1 -2*zetadel*wdel wdel*wdel],[1 2*zetadel*wdel wdel*wdel]);

int1 = nd2sys(1,[1 0]);
int2 = nd2sys(1,[1 0]);
c1 = wrud^2;
c2 = wrud^2;
c3 = 2*zetarud*wrud;
systemnames = 'c1 c2 c3 int1 int2';
inputvar = '[u]';
outputvar = '[int2;int1;c1-c2-c3]';
input_to_c1 = '[u]';
input_to_c2 = '[int2]';
input_to_c3 = '[int1]';
input_to_int1 = '[c1-c2-c3]';
input_to_int2 = '[int1]';
sysoutname = 'rudder';
cleanupsysic = 'yes';
sysic
actrud = mmult(rudder,delaytf);

int1 = nd2sys(1,[1 0]);
int2 = nd2sys(1,[1 0]);
c1 = wele^2;
c2 = wele^2;
c3 = 2*zetaele*wele;
systemnames = 'c1 c2 c3 int1 int2';
inputvar = '[u]';
outputvar = '[int2;int1;c1-c2-c3]';
input_to_c1 = '[u]';
input_to_c2 = '[int2]';
input_to_c3 = '[int1]';
input_to_int1 = '[c1-c2-c3]';
input_to_int2 = '[int1]';
sysoutname = 'elevon';
cleanupsysic = 'yes';
sysic
actele = mmult(elevon,delaytf);
% -----------------------------------------------------------%
%
%