function resetsys(this)
%RESETSYS  Clears cached data in lti sources.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/04 15:19:23 $

% RE: Used, e.g., at the end of a mouse edit to force refreshing 
%     the adaptive time or freq. grids
for s=this.Systems'
   % Clear all data except what depends only on the model
   % RE: Assumes that the model has not changed
   reset(s,'Time')
   reset(s,'Frequency')
end