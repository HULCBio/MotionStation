function [mg] = freqrc(varargin)
%FREQRC Continuous complex frequency response (MIMO).
%
% [G] = FREQRC(SS_,W) or
% [G] = FREQRC(A,B,C,D,W) produces a matrix G containing
% the complex frequency response :
%                                  -1
%     G(s) = Y(s)/U(s) = C(sI - A)   B + D
%
% of the linear system described in  state space as :
%             .
%             x = Ax + Bu
%             y = Cx + Du
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
% ------------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,w]=mkargs5x('ss',varargin); error(emsg);

% discrete case (call DCFREQRC)   
if Ts, 
   [mg] = dfreqrc(varargin{:},abs(Ts));
   return
end   

% continuous case

[rb,cb] = size(b);
%
% Calculating G(jw) :
%
[p,a] = hess(a);
b = p'*b;
c = c*p;
%
for iu = 1 : cb
    [g] = clxbode(a,b,c,d,iu,w);
    if iu == 1
       mg = g;
    else
       mg = [mg;g];
    end
end
%
% ------ End of FREQRC.M --- RYC/MGS 5/16/85 %
