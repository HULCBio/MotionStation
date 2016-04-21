function scribetextdlg(selection)
%SCRIBETEXTDLG  Edit Text and Font Properties in Plot Editor

% takes a selection list: a row vector of scribehandle objects

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:08:23 $

if isempty(selection)
   LNoTextError
   return
end

% keep only those objects that have the right properties
fontObjects = [];
for aObj = selection
   % change for R12 interim: don't edit axis objects
   if isa(aObj,'axistext') % | isa(aObj,'axisobj') 
      HG = get(aObj,'MyHGHandle');
      fontObjects(end+1) = HG;
   end
end

if isempty(fontObjects)
   LNoTextError
   return
end


%--temporary:  redirect to Property Editor
% select only the first object in the selection
% this is probably a little confusing for axes:  we should
% open the axes page to the right panel if that's what we
% want to edit.  
% propedit(fontObjects);
% return;


% get text properties from the selected objects
fontProps = {'FontName', 'FontUnits', 'FontSize', ...
           'FontWeight', 'FontAngle'};
fontVals = get(fontObjects, fontProps);
fontUnits = fontVals(:,2);

types = get(fontObjects,'Type');

if strcmp(types, 'axes')
   dlgTitle = 'Edit Axes Font Properties';
else
   dlgTitle = 'Edit Font Properties';
end

% for now, simply fill the dialog with the properties for the
% first object in the list
propValList = [fontProps; fontVals(1,:)];
propStruct = struct(propValList{:});


returnStruct = uisetfont(propStruct, dlgTitle);


if ~isstruct(returnStruct)  % uisetfont returns 0 for cancel
   return
end

% set new properties
set(fontObjects, returnStruct);
% restore original units
set(fontObjects, {'FontUnits'}, fontUnits);



function LNoTextError
errordlg('No text is selected.  Click on a text object to select it.');
