% function [erow1, erow] = emargin(system,controller,ttol)
%
% Calculates the normalized coprime factor/gap metric robust stability
% margin, for a feedback loop with a given SYSTEM and CONTROLLER,
% and a positive feedback convention.
%
% SYSTEM:     state-space system to be tested.
% CONTROLLER: controller to be tested.
% TTOL:       gives the required precision (default is 0.001).
%
% EROW1:      upper bound for the normalized coprime factor/gap metric
%	        robust stability margin.
% EROW:       a 1x3 row vector, with the upper bound, lower bound and
%               and the frequency where the upper bound occurs.
%
% See also HINFNORM, SNCFBAL, GAP, NUGAP

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [erow1, erow] =emargin(system,controller,ttol)

if (nargin ~=2 & nargin ~= 3),
  disp('usage:  [erow1, erow] = emargin(system,controller)')
  return
end
if nargin == 2
  ttol=1E-3;
end

[type, outp, inp, dimp]=minfo(system);
[type, outc, inc, dimc]=minfo(controller);
if (inp~=outc | inc~=outp)
  disp('size of system and plant incompatible')
  return
end

% Pnew=sel(system,[1,outp 1:outp],[1:inp 1:inp]);
Pnew=sel(system,[1:outp 1:outp],[1:inp 1:inp]);
Pnew=abv(sbs(Pnew,[zeros(outp,outp); eye(outp,outp)]),...
         sbs(eye(inp,inp),eye(inp,inp),zeros(inp,outp)));
Pnew=sel(Pnew,[1:outp 2*outp+1:2*outp+inp outp+1:2*outp],...
              [1:inp 2*inp+1:2*inp+outp inp+1:2*inp]);
pp=starp(Pnew,controller);
erow=hinfnorm(pp,ttol);
erow1=inv(erow(1));