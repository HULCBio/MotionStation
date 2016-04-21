%---------------------------- mk_olic ---------------------------%
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
 systemnames = 'acnom wr wl wnoise wact wgust wphicmd wperf idmod';
 systemnames = [systemnames ' actele actrud'];
 inputvar = '[pertin{9} ; noise{4} ; gust ; comd ; elec ; rudc]';
 outputvar = '[wr; wperf; wact ; wphicmd; acnom(4:7) + wnoise]';
 input_to_acnom = '[wl ; actele(1) ; actrud(1) ; wgust ]';
 input_to_wl = '[pertin]';
 input_to_wr = '[acnom(1:3)]';
 input_to_wnoise = '[noise]';
 input_to_wact = '[actele ; actrud]';
 input_to_wgust = '[gust]';
 input_to_wphicmd = '[comd]';
 input_to_wperf = '[acnom(4:7) ; idmod]';
 input_to_idmod = '[wphicmd]';
 input_to_actele = '[elec]';
 input_to_actrud = '[rudc]';
 cleanupsysic = 'yes';
 sysoutname = 'olic';
 sysic
 disp('The Interconnection Structure is in "olic"')
 disp(' ')
 minfo(olic)

%--------------------------------------------------------------------%
%
%