function highlite(hThis,arg)
% This gets called when the user clicks on/off anywhere 
% on the datatip. It effectively highlites the datatip 
% by darkening the text box border.

% Copyright 2003 The MathWorks, Inc.

switch arg
  case 'on'
     set(hThis.TextBoxHandle,'EdgeColor',[0 0 0]);
  case 'off'
     set(hThis.TextBoxHandle,'EdgeColor',hThis.EdgeColor);
end

