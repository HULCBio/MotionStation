function [ticks,limits] = phaseticks(ticks,limits,DataExtent)
%PHASETICKS  Generate ticks multiple of 45 degrees for phase plots
%
%   [NEWTICKS,NEWLIMS] = PHASETICKS(TICKS,LIMS,DataExtent) takes the 
%   HG-generated TICKS and axis LIMS and computes new ticks and limits
%   that are multiple of 45 degrees (when the phase variation is greater 
%   than 90 degrees).  The true data extent is taken into account to 
%   compute the new axis limits.
%
%   NEWTICKS = PHASETICKS(TICKS,LIMS) computes new ticks for the fixed
%   phase interval LIMS.
%
%   See also BODE, MARGIN, NICHOLS.

%   Author: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $   $Date: 2002/04/10 04:43:13 $

%  REVISIT: not aware of phase units!! Assumes degrees

inc = 45;  % 45 degree increments

% Determine data extent within HG limits (to account for manual 
% limit settings)
if (nargin<3) | isempty(DataExtent)
   DataExtent = limits;
elseif abs(DataExtent(2)-DataExtent(1))<10,
   % min. extent of 10 degrees to prevent zero extent and noisy display
   DataExtent = round((DataExtent(1)+DataExtent(2))/2) + [-5,5];
else
   DataExtent(1) = max(DataExtent(1),limits(1));
   DataExtent(2) = min(DataExtent(2),limits(2));
end

% Determine number of INC sections within current axis limits
ns = (limits(2)-limits(1))/inc;

% Determine the number of tick sections
nticks = max([1 (limits(2)-limits(1))./max(diff(ticks))]);

% Override HG default when phase variation exceeds 45 degrees
if ns>1
   if ns<=2,
      % Use a 30 degree period
      period = 30;
   else
      % Find adequate tick period (of the form 2^k * INC) 
      k = round(log2(ns/nticks));
      period = inc * 2^max(0,k);
   end
   
   % Reset limits taking true data extent into account
   limits(1) = period * floor(DataExtent(1)/period);
   limits(2) = period * ceil(DataExtent(2)/period);
   
   % Generate new ticks
   ticks = limits(1):period:limits(2);
end
