function g = delayfr(DelayMatrix,s)
%DELAYFR  Frequency response of continuous delay system.
%
%    G = DELAYFR(DT,S) computes the frequency response of the
%    continuous-time LTI model with pure I/O delays DT   
%
%     y(1) = exp(-s*DT(1,1))*u(1) + exp(-s*DT(1,2))*u(2) + ...
%     y(2) = exp(-s*DT(2,1))*u(1) + exp(-s*DT(2,2))*u(2) + ...
%       ...
%
%    at the vector of complex frequencies S.  The matrix DT 
%    specifies the delay times for each input/output pair.
%    The output G is a NY-by-NU-by-NW array if there are
%    NY outputs, NU inputs, and NW frequency points.
%
%    See also FREQRESP.

%    Author: P. Gahinet, 7-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.13 $  $Date: 2002/04/10 06:38:33 $


% Get dimensions and preallocate G
nw = length(s);
s = reshape(s,[1 nw]);
sizes = size(DelayMatrix);
nsys = prod(sizes(3:end));
nio = prod(sizes(1:2));
g = zeros([nio nw nsys]);

% Compute response for each model (evaluate as EXP(-DT(:)*S))
for k=1:nsys,
   g(:,:,k) = exp(reshape(-DelayMatrix(:,:,k),[nio 1])*s);
end

% Reformat
g = reshape(g,[sizes(1:2) nw sizes(3:end)]);

