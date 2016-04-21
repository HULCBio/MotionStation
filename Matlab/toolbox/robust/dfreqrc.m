function [mg] = dfreqrc(varargin)
%DFREQRC Discrete complex frequency response (MIMO).
%
% [G] = DFREQRC(SS_,W,TS) or
% [G] = DFREQRC(A,B,C,D,W,TS) produces a matrix G containing
% the complex frequency response :
%                                  -1
%     G(z) = Y(z)/U(z) = C(zI - A)   B + D
%
% of the linear system described in  state space as :
%
%             x(k+1) = Ax(k) + Bu(k)
%             y(k) = Cx(k) + Du(k)
%
% when evaluated at the frequencies in complex vector W.
% Returned in G is a matrix where each column corresponds to a
% frequency point in W, and each row corresponds to a particular
% U-Y pair. The first ny rows, where ny is the size of the Y vector,
% correspond to the responses from the first input. And so on up to
% ny * nu where nu is the size of the U vector.

% R. Y. Chiang & M. G. Safonov 5/16/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
%-------------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,w,Ts]=mkargs5x('ss',varargin); error(emsg);

[rb,cb] = size(b);
%
% Calculating G(z) :
%
[p,a] = hess(a);
b = p'*b;
c = c*p;
%
for iu = 1 : cb
    [g] = dclxbode(a,b,c,d,iu,w,Ts);
    if iu == 1
       mg = g;
    else
       mg = [mg;g];
    end
end
%
% ------- End of DFREQRC.M --- RYC/MGS 5/16/85 %
