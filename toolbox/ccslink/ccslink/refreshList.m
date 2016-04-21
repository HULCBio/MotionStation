function refreshList(hObject,handles)
% Refresh list in dataTypeInspector GUI.
% Called by dataTypeInspector() and dataTypeList().

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/08 20:47:28 $

% Create new typedef list
handles.typelist = handles.cc.type.typelist;
TypedefList = [];
len = length(handles.typelist);
for i=1:len
    TypedefList{i} = [ handles.typelist{i}.name ' (' handles.typelist{i}.basetype.type ')' ];
end

% If highlight is not within new range (i.e. if last entry is removed)
% set to valid listbox value
currentListboxVal = get(handles.TypeEqvPairList,'Value');
if isempty(TypedefList)
    set(handles.TypeEqvPairList,'Value',1);
elseif currentListboxVal>len
    set(handles.TypeEqvPairList,'Value',len);
end

% If highlight is not within new range (i.e. if no entry is retained),
% set to valid listbox value
if isempty(TypedefList)
    TypedefList = {TypedefList};
end

% Set to new typedef list
set(handles.TypeEqvPairList,'String',TypedefList);

% [EOF] refreshList.m