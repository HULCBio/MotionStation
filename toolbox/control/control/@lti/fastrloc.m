function r = fastrloc(sys,gains)
%FASTRLOC  Modified version of RLOCUS.
%
%   Used in SISOTOOL and optimized for speed.
%
%   See also SISOTOOL.

%   Author: P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:52:21 $

% RE: * GAINS must be a row vector
%     * expects zero-pole-gain model

[z,p,k] = zpkdata(sys,'v');
reldeg = length(z)-length(p);

% Compute and sort roots
if k==0
   r = zeros(0,length(gains));
   
elseif reldeg<=0
   % proper
   [a,b,c,d] = fastss(sys);  
   r = genrloc(a,b,c,d,gains,z,p,'sort');
   
else
   % improper: reduce to proper using G->1/G
   iszero = (~gains);
   gains(iszero) = Inf;
   gains(~iszero) = 1./gains(~iszero);
   
   [a,b,c,d] = fastss(inv(sys));
   r = genrloc(a,b,c,d,gains,p,z,'sort');
end

