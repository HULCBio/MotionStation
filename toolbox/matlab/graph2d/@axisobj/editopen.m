function aObj = editopen(aObj)
%AXISOBJ/EDITOPEN Edit axisobj object
%   This file is an internal helper function for plot annotation.

%   edit axis properties on double click

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.2 $  $Date: 2004/01/15 21:11:41 $

selection = get(getobj(get(aObj,'Figure')),'Selection');

%get a list of all handles currently selected in figure
if ~isempty(selection)
    hList = subsref(selection,substruct('.','HGHandle'));
    if iscell(hList)
        hList=[hList{:}];
    end
else
    hgobj = aObj.scribehgobj;
    if ~isempty(hgobj)
        hList=hgobj.HGHandle;
    else
        hList=get(gcf,'CurrentAxes');
    end
end
    
propedit(hList,'v6','-noselect');