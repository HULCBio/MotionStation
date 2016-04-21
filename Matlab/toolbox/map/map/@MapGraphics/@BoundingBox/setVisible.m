function setVisible(this,b)
%SETVISIBLE
%
%   SETVISIBLE(B) Sets the graphics components to be visible (B = 'On' or true)
%   or invisible (B = 'Off' or false).

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:28 $

if islogical(b)
  if b
    b = 'On';
  else
    b = 'Off';
  end
end

set([this.LineHandle, handle(this.TextHandle)],'Visible',b);
