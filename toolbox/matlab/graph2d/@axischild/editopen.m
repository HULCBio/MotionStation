function aObj = editopen(aObj)
%AXISCHILD/EDITOPEN Edit axischild
%   This file is an internal helper function for plot annotation.

%   edit on doubleclick

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.2 $  $Date: 2004/01/15 21:11:31 $

selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList)
    hList=[hList{:}];
end
    
propedit(hList,'v6','-noselect');



