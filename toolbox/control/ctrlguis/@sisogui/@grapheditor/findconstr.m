function Constraints = findconstr(Editor)
%FINDCONSTR   Finds all design constraints objects attached to an Editor.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:02:03 $

Constraints = find(Editor, '-isa', 'plotconstr.designconstr');

