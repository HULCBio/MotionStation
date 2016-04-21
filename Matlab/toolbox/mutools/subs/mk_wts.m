%------------------------- mk_wts ----------------------------%
%
%   This makes up the weighting functions

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $


% EXOGENOUS SIGNALS
%
%   WIND
    wgust = nd2sys([.5 1],[1 1],30);

%   SENSOR NOISE (
    wr = nd2sys([100 1],[2 1],.0003);     % rads/sec
    wp = wr;                              % rads/sec
    wphi = nd2sys([100 1],[.5 1],0.0007); % rads
    wny = nd2sys([20 1],[.1 1],.25);      % ft/sec/sec

    wnoise = daug(wp,wr,wny,wphi);


%   PILOT COMMAND
    wphicmd = nd2sys([.5 1],[2 1],.5);

%  ERROR WEIGHTING
%   ACTUATOR WEIGHTINGS
    wact = diag([4 1 .005 2 .2 .009]);

% IDEAL PHI_COMMAND RESPONSE MODEL
   wmod = 1.2;
   zmod = .7;
   idmod = nd2sys(wmod*wmod,[1 2*zmod*wmod wmod*wmod]);


%   PERFORMANCE VARIABLES
    nyerr = nd2sys([1 1],[10 1],.8);
    cterr = nd2sys([1 1],[100 1],500);
    baerr = nd2sys([1 1],[100 1],250);
    fix = [0 0 1 0 0;0 1 0 -0.037 0;0 0 0 1 -1];
    wperf = mmult(daug(nyerr,cterr,baerr),fix);

% PERTURBATION WEIGHTS
    wr = [1 0 0;1 0 0;1 0 0;0 1 0;0 1 0;0 1 0;0 0 1;0 0 1;0 0 1];
    wll = diag([2.194 -1.517 -.718]);
    wlm = diag([-1.327 1.347 .5185]);
    wlr = diag([-.3656 .8667 .2347]);
    wl = [wll wlm wlr];
%--------------------------------------------------------%
%
%