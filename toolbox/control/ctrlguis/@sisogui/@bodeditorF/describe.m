function Str = describe(Editor,KeyWord)
%DESCRIBE  Returns description for editor-specific variables

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:03:46 $

switch lower(KeyWord(1:4))
case 'gain'
	FilterID = Editor.LoopData.describe('F','compact');
    Str = sprintf('%s gain',lower(FilterID));
case 'comp'
	Str = Editor.LoopData.describe('F');
end