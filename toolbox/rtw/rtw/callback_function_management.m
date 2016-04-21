function callback_function_management (varargin)
% CALLBACK_FUNCTION_MANAGEMENT - Real-Time Workshop internal routine.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.11 $

if (nargin == 0)
  dialogFig = get (gcbo, 'Parent');
else
  dialogFig = varargin{1};
end

functionSplit = 'Function split threshold';
fileSplit = 'File split threshold';
dialogUserData = get(dialogFig, 'UserData');
hModel = dialogUserData.model;

loDefault = get_param(hModel,'OptimizeBlockIOStorage');

val_to_string{1} = 'off';
val_to_string{2} = 'on';

% switch on the value of dialogUserData
% Set enable 'on' for edit field
o = findobj (dialogFig, 'Tag', 'Function management_PopupFieldTag');
val = get(o,'Value');
switch(val)
case (1)
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'off');
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'off');

  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'off');
  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'off');
  % Turn on ShowEliminatedStatements checkbox
  obj = findobj (dialogFig, 'Tag', 'Show eliminated statements_CheckboxTag');
  set (obj, 'Enable', 'on');
  % Turn on LocalBlockOutputs checkbox
  obj = findobj (dialogFig, 'Tag', 'Local block outputs_CheckboxTag');
  set(obj, 'Enable', loDefault);

  
case (2)
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'on');
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'on');

  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'off');
  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'off');
  % Turn on ShowEliminatedStatements checkbox
  obj = findobj (dialogFig, 'Tag', 'Show eliminated statements_CheckboxTag');
  set (obj, 'Enable', 'on');
  % Turn off LocalBlockOutputs checkbox
  obj = findobj (dialogFig, 'Tag', 'Local block outputs_CheckboxTag');
  set (obj, 'Enable', 'off');

case (3)
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'off');
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'off');

  obj = findobj (dialogFig, 'Tag', [fileSplit,'_EditLabelTag']);
  set (obj, 'Enable', 'on');
  obj = findobj (dialogFig, 'Tag', [fileSplit,'_EditFieldTag']);
  set (obj, 'Enable', 'on');
  
  % Shut off ShowEliminatedStatements checkbox
  obj = findobj (dialogFig, 'Tag', 'Show eliminated statements_CheckboxTag');
  set (obj, 'Enable', 'off');
  % Turn on LocalBlockOutputs checkbox
  obj = findobj (dialogFig, 'Tag', 'Local block outputs_CheckboxTag');
  set(obj, 'Enable', loDefault);

case (4)
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'on');
  obj = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'on');

  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditLabelTag']);
  set (obj, 'Enable', 'on');
  obj = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
  set (obj, 'Enable', 'on');
  
  % Shut off ShowEliminatedStatements checkbox
  obj = findobj (dialogFig, 'Tag', 'Show eliminated statements_CheckboxTag');
  set (obj, 'Enable', 'off');
  % Turn off LocalBlockOutputs checkbox
  obj = findobj (dialogFig, 'Tag', 'Local block outputs_CheckboxTag');
  set (obj, 'Enable', 'off');

end
