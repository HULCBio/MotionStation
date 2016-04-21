function bbox = getAxesLimits(this)
%GETAXESLIMITS
%
%   Returns the axes lower-left and upper-right corners [lower-left-x,y;
%   upper-right-x,y],
%   
%      or equivalently,  [left      bottom;
%                         right        top]

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:09 $

bbox = zeros(2,2);

bbox(:,1) = this.Xlim(:);
bbox(:,2) = this.Ylim(:);