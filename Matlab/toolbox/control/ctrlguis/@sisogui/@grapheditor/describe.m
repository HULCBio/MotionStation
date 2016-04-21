function Str = describe(Editor,KeyWord)
%DESCRIBE  Returns description for editor-specific variables

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:01:42 $

switch KeyWord
case 'gain'
    Str = 'loop gain';
case 'comp'
	Str = Editor.LoopData.describe('C');
end