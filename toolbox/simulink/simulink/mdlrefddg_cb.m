function mdlrefddg_cb(dialogH)
%MDLREFDDG_CB Model Reference block dialog callbacks.
%   Internal function used by the model reference dialog.
%
%   Copyright 1990-2003 The MathWorks, Inc.
  
  if isempty(dialogH) || ~ishandle(dialogH)
    error('Did not receive a valid dialog handle in mdlgrefddg_cb.m');
    return;
  end
  
  % The edit field tag is simply the field prompt. If it changes,
  % then this tag has to be updated as well.
  modelFieldTag = 'Model name (without the .mdl extension):';
  
  % Try getting the field value. It can be ''.
  modelName = dialogH.getWidgetValue(modelFieldTag);
  if isempty(modelName) || ~ischar(modelName)
    return;
  end
  
  % Try opening the model. Any errors will be caught and shown by the
  % diagnostic viewer.
  open_system(modelName);