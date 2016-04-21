function [h] = linkprop(h,p)
%LINKPROP Maintain same value for corresponding properties
%  Use LINKPROP to maintain the same values for the 
%  corresponding properties of different objects.
%
%  HLINK = LINKPROP(H,'PropertyName'); 
%  Maintains the same value for the property 'PropertyName' 
%  on all objects whose handles appear in H. LINKPROP returns
%  the link object HLINK. 
% 
%  HLINK = LINKPROP(H,{'PropertyName1','PropertyName2',...});
%  Maintains the same value for all properties passed as a cell 
%  array. 
%
%  It is necessary that the link object remain referenced 
%  within the context of where you want property linking 
%  to occur. You can keep the link object as a variable 
%  in the base workspace, make the link object GLOBAL, 
%  or store the link object in USERDATA property or 
%  in application data (SETAPPDATA). 
%       
%  Example:
%  h1 = line('xdata',1:10,'ydata',1:10);
%  h2 = line('xdata',1:10,'ydata',10:-1:1);
%  hlink = linkprop([h1,h2],'Color');
%  set(h1,'Color',[.3 .4 .5])
%  get(h2,'Color') % returns [.3 .4 .5] 
%
%  See also LINKAXES, SETAPPDATA, GLOBAL

% Copyright 2003 The MathWorks, Inc.

h = graphics.linkprop(h,p);

