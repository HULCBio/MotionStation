function asap2_make_rtw_hook(varargin)
% ASAP2_MAKE_RTW_HOOK - ASAP2 target-specific hook file for the build process (make_rtw).

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/04/14 18:42:51 $

persistent MODEL_SETTINGS

Action    = varargin{1};
modelName = varargin{2};
buildArgs = varargin{6};

switch Action
case 'entry'
  % Check property settings for generation of ASAP2 file.
  % Record old settings if being changed for duration of ASAP2 generation process.
  if strcmp(get_param(modelName, 'RTWInlineParameters'), 'off')
    MODEL_SETTINGS.RTWInlineParameters = 'off';
    set_param(modelName, 'RTWInlineParameters', 'on');
    warning('Setting: RTWInlineParameters = ''on'' during ASAP2 generation process');
  end
  
  if strcmp(get_param(modelName, 'RTWGenerateCodeOnly'), 'off')
    MODEL_SETTINGS.RTWGenerateCodeOnly = 'off';
    set_param(modelName, 'RTWGenerateCodeOnly', 'on');
    warning('Setting: RTWGenerateCodeOnly = ''on'' during ASAP2 generation process');
  end
  
case 'exit'
  disp(['### Successful completion of Real-Time Workshop build ',...
	'procedure for model: ', modelName]);
  
  % Restore property settings as they were before generating ASAP2 file.
  if ~isempty(MODEL_SETTINGS)
    modelPropertiesToRestore = fieldnames(MODEL_SETTINGS);
    for i = 1:length(modelPropertiesToRestore)
      thisProperty = modelPropertiesToRestore{i};
      thisSetting  = getfield(MODEL_SETTINGS, thisProperty);
      set_param(modelName, thisProperty, thisSetting);
      disp(['Restoring: ', thisProperty, ' = ''', thisSetting, '''']);
    end
    MODEL_SETTINGS = [];
  end
end


