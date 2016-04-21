function RootObj = root(Editor)
%ROOT  Finds root object in GUI hierarchy.
%
%   See also SISOTOOL.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 05:01:39 $

RootObj = Editor.up;