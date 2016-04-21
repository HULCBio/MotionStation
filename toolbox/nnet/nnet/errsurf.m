function m = errsurf(p,t,wv,bv,f)
%ERRSURF Error surface of single input neuron.
%
%  Syntax
%
%    E = errsurf(P,T,WV,BV,F)
%
%  Description
%  
%    ERRSURF(P,T,WV,BV,F) takes these arguments,
%      P  - 1xQ matrix of input vectors.
%      T  - 1xQ matrix of target vectors.
%      WV - Row vector of values of W.
%      BV - Row vector of values of B.
%      F  - Transfer function (string).
%    and returns a matrix of error values over WV and BV.
%         
%  Examples
%
%    p = [-6.0 -6.1 -4.1 -4.0 +4.0 +4.1 +6.0 +6.1];
%    t = [+0.0 +0.0 +.97 +.99 +.01 +.03 +1.0 +1.0];
%    wv = -1:.1:1; bv = -2.5:.25:2.5;
%    es = errsurf(p,t,wv,bv,'logsig');
%    plotes(wv,bv,es,[60 30])
%
%  See also PLOTES.

% Mark Beale, 1-31-92.
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:35:08 $

if nargin < 5,error('Not enough input arguments.');end

m = zeros(length(bv),length(wv));
for Y=1:length(bv);
  m(Y,:) = sum((t'*ones(1,length(wv))-feval(f,p'*wv+bv(Y))).^2,1);
end
