function setDataTipMode(this,State)
% Updates set of objects users can interact with

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/11 00:44:50 $
hConstr = cat(1,this.LowerBound.Surf,this.LowerBound.Line,...
   this.UpperBound.Surf,this.UpperBound.Line);
hResp = double(this.Reference);
for ct=1:length(this.TestViews)
   hResp = cat(1,hResp,this.TestViews(ct).Response(:),this.TestViews(ct).Optimization(:));
end
hResp = hResp(ishandle(hResp));
% Toggle HitTest settings
switch State
   case 'on'
      % Data tip mode is on
      set(hResp,'HitTest','on')
      set(hConstr,'HitTest','off')
   case 'off'
      set(hResp,'HitTest','off')
      set(hConstr,'HitTest','on')
end
   