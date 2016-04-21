function adjustview(this,Event)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(C,'prelim') is invoked before updating the limits.
%  ADJUSTVIEW(C,'postlim') is invoked in response to a LimitChanged event.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:00 $
if strcmp(this.Visible, 'on')
   % Adjust visible characteristic views 
   NormalRefresh = strcmp(this.RefreshMode,'normal');
   for ct=1:length(this.View)
      if ~this.Data(ct).Exception && strcmp(this.View(ct).Visible,'on')
         adjustview(this.View(ct),this.Data(ct),Event,NormalRefresh)
      end
   end
end