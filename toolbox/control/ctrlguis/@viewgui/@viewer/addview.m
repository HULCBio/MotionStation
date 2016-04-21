function Views = addViews(this,plottypes)
%ADDVIEW   Adds one or several views to @viewer instance.
%
%   ADDVIEW(VIEWER,PLOTTYPE) adds a view of type PLOTTYPE 
%   (a string).
%
%   ADDVIEW(VIEWER,{PLOT1,PLOT2,...}) adds views of types  
%   PLOT1, PLOT2, ...

%   Author(s): Kamesh Subbarao 
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/03/11 01:40:27 $

if ischar(plottypes)
   plottypes = {plottypes};
end

% Create the Views
AvailablePlotTypes = {this.AvailableViews.Alias};
Nplots = length(plottypes);
Views = handle(-ones(Nplots,1)); % REVISIT
for ctV = 1:Nplots
   indp  = find(strcmpi(plottypes{ctV},AvailablePlotTypes));
   if length(indp)~=1
      error(sprintf('Unknown or ambiguous plot type %s.',plottypes{ctV}))
   end
   Views(ctV,1) = feval(this.AvailableViews(indp).CreateFcn{:});
end
