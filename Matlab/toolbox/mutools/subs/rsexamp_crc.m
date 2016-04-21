% Example for ROBUST STABILITY Analysis
%
% M = rsexamp;

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

        %       Multiplicative Uncertainty Weight
        wu = nd2sys([6.5 8],[1 42]);

        %       Error Weight for Performance
        wperf = 0.125;

        %       Sensor Noise Weighting
        sennois = 0.2;

        %       2-state Plant with parametric uncertainty
        zeta  = 0.02;
        w1    = 4;
        zunc  = 0.40;
        H   = pck([0 1;-w1^2 -2*zeta*w1],[0 0;1 1],[zunc*w1^2 0;w1^2 0]);

        %       SYSIC code for interconnection
        systemnames = 'wu H wperf sennois';
        sysoutname = 'olp';
        inputvar = '[w1; w2; d; n; u]';
        input_to_H      = '[ w1; u + d + w2 ]';
        input_to_wu    = '[ u + d ]';
        input_to_wperf    = '[ H(2) ]';
        input_to_sennois  = '[ n ]';
        outputvar = '[H(1); wu; wperf; H(2) + sennois]';
        cleanupsysic = 'yes';
        sysic

        %       Controller
        num = [ -12.56 17.32 67.28];
        den = [ 1 20.37 136.74 179.46];
        K = nd2sys(num,den);

        %       Form Closed-Loop Interconnection
        M = starp(olp,K);