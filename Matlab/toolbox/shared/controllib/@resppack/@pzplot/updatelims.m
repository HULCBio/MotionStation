function updatelims(this)
%UPDATELIMS  Limit picker for pole/zero plots.

%  Author(s): K. Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:13 $

% Unit circle visibility
if anydiscrete(this)
   set(this.BackgroundLines(:,:,4),'Visible','on')
else
   set(this.BackgroundLines(:,:,4),'Visible','off')
end
   
% Delegate to @axesgrid
updatelims(this.AxesGrid)

% Enforce symmetry of Y limits in auto mode
this.ylimconstr('Symmetry','on')
