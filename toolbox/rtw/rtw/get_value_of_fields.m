% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $
% $Date: 2002/04/10 17:53:39 $
function get_value_of_fields (hModel,dialogFig,transition)

modelName = get_param (hModel, 'Name');
eval (['global ', modelName,'_FunctionFileSplitThresholds;']);
eval (['local = ',modelName,'_FunctionFileSplitThresholds;']);

functionSplit = 'Function split threshold';
fileSplit = 'File split threshold';

switch(transition)
case('open')
  if (isfield (local,'AlreadyDeclared'))
    o = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
    set (o,'String',local.FileSplitThreshold);
    
    o = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
    set (o,'String',local.FunctionSplitThreshold);
  else
    local.AlreadyDeclared = 1;

    o = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
    local.FileSplitThreshold = get (o,'String');
    
    o = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
    local.FunctionSplitThreshold = get (o,'String');
  end
case('close')
  o = findobj (dialogFig, 'Tag', [fileSplit, '_EditFieldTag']);
  local.FileSplitThreshold = get (o,'String');

  o = findobj (dialogFig, 'Tag', [functionSplit, '_EditFieldTag']);
  local.FunctionSplitThreshold = get (o,'String');
otherwise
  error ('Unknown transition in get_value_of_fields.m.');
end

eval ([modelName,'_FunctionFileSplitThresholds = local;']);
