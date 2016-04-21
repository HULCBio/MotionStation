function refreshmargin(Editor)
%REFRESHMARGIN  Dynamic update of stability margins in Nichols Editor.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:05:11 $

% Quick exit if margins off
if strcmp(Editor.MarginVisible, 'on'),
   % Interpolate stability margins 
   Magnitude = Editor.Magnitude * getzpkgain(Editor.EditedObject,'mag');
   [Gm, Pm, Wcg, Wcp] = imargin(Magnitude(:), Editor.Phase(:), ...
      Editor.Frequency(:));
   
   % Update display
   Editor.showmargin(struct('Gm', Gm, 'Pm', Pm, ...
      'Wcg', Wcg, 'Wcp', Wcp, 'Stable', NaN));
end
