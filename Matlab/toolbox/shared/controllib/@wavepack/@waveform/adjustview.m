function adjustview(this,Event)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(R,'prelim') is invoked before updating the limits.
%  ADJUSTVIEW(R,'postlim') is invoked in response to a LimitChanged event.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:06 $
if strcmp(this.Visible, 'off')
   return
end

% Adjust visible response curves 
NormalRefresh = strcmp(this.RefreshMode,'normal');
for ct=1:length(this.View)
   if ~this.Data(ct).Exception && strcmp(this.View(ct).Visible,'on')
      % Proceed only if data is valid and view is visible
      adjustview(this.View(ct),this.Data(ct),Event,NormalRefresh)
   end
end

% Adjust characteristics objects
if ~isempty(this.Characteristics)
   for c=find(this.Characteristics,'Visible','on')' % for speed
      adjustview(c,Event)
   end
end
