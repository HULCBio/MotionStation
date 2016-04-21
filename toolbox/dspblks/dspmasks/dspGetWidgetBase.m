function dlgstruct = dspGetWidgetBase(type,name,tag,prop)
%getWidgetBase Signal Processing Blockset Dynamic Dialog block helper function.
%
%   getWidgetBase(type,name,tag,prop)
%   Returns a MATLAB structure for use with Dynamic Dialogs
%   The structure has several common fields filled out:
% 
%    type: Type
%    name: Name
%    tag:  Tag
%    prop: ObjectProperty (optional)
%    
%   Also, the struct has Mode set to 1 unles the widget type is 
%   group, panel, togglepanel, or tab
%   

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:05:50 $


error(nargchk(3,4,nargin,'struct'));

if ~(isstr(type) && isstr(name) && isstr(tag)) || ...
      ((nargin == 4) && ~isstr(prop))
  error('Inputs to getWidgetBase must all be strings.');
end

dlgstruct.Type = type;
dlgstruct.Name = name;
dlgstruct.Tag = tag;
if nargin >= 4
  dlgstruct.ObjectProperty = prop;
end

if ~any(strcmp(type,{'panel','togglepanel','tab','group'}))
  dlgstruct.Mode = 1;
end
