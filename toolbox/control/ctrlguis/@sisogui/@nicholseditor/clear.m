function clear(Editor)
%CLEAR  Clears Nichols plot objects.
%
%   Clears the graphical objects making up the Nichols plot (excluding reusable 
%   objects such as the stability margin markers)

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/04/10 05:04:47 $

% Delete HG objects
HG = Editor.HG;
Handles = [HG.NicholsPlot; ...
      HG.Compensator; ...
      HG.System];
delete(Handles(ishandle(Handles)));

% Also clear margin text when open-loop transfer is not defined
if Editor.SingularLoop & ~isempty(Editor.HG.Margins)
   set(Editor.HG.Margins.Text,'String','')
end

% REVISIT
set(HG.NicholsShadow,'XData',[],'YData',[],'ZData',[])
