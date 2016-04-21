function ydata = normalize(this,ydata,Xlims,varargin)
%NORMALIZE  Scales Y data to normalized time data range.
%
%  Input arguments:
%    * YDATA is the Y data to be normalized
%    * XLIMS are the X limits for the axes of interest
%    * The last argument(s) is either an absolute index or a pair
%      of row/column indices specifying the axes location in the 
%      axes grid.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:35 $
[ns,ny,nu] = size(this.Amplitude);
if ny>0
   [ymin,ymax,FlatY] = ydataspan(this.Time,this.Amplitude,Xlims);
   ydata = (ydata - (ymin+ymax)/2)/((ymax-ymin)/2+FlatY);
end
