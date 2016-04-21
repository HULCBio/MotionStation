function aObj = editopen(aObj)
%EDITLINE/EDITOPEN Edit editline object
%   This file is an internal helper function for plot annotation.

%   open edit dialog on double click

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.17.4.2 $  $Date: 2004/01/15 21:12:19 $


selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
hList = subsref(selection,substruct('.','HGHandle'));
if iscell(hList)
    hList=[hList{:}];
end
    
propedit(hList,'v6','-noselect');