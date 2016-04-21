%-------------------------- mk_olsim ---------------------%
%
% This program creates the open-loop interconnection
%   for the SSLAFCS (Space Shuttle Lateral Axis Flight
%   Control System)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

% Make 4-state aircraft model
  mk_acnom
% Creates: acnom

% Make actuator models (rudder and elevon)
  mk_act
% Creates: actele, actrud

% Make shaping filters (performance weights, ideal models)
  mk_wts
% Creates: wl, wr, wnoise, wact, wgust, wphicmd, wperf, idmod


% SYSIC program to form interconnection
 systemnames = 'acnom wr wl idmod';
 systemnames = [systemnames ' actele actrud'];
 inputvar = '[pertin(9) ; gust ; comd ; elec ; rudc]';
 outputvar = '[wr; acnom(7) ; acnom(6) ; acnom(5)-0.037*acnom(7);';
 outputvar = [outputvar 'acnom(7)-idmod;actele;actrud;comd;'];
 outputvar = [outputvar 'acnom(4:7)]'];
 input_to_acnom = '[wl ; actele(1) ; actrud(1) ; gust ]';
 input_to_wl = '[pertin]';
 input_to_wr = '[acnom(1:3)]';
 input_to_idmod = '[comd]';
 input_to_actele = '[elec]';
 input_to_actrud = '[rudc]';
 cleanupsysic = 'yes';
 sysoutname = 'olsim';
 sysic
 disp('The Interconnection Structure is in "olsim"')
minfo(olsim)
%--------------------------------------------------------------%