function rtwconfiguredemo(model,fpMode,forGRT,overrides)
% RTWCONFIGUREDEMO - Configure a model for a Real-Time Workshop
% demonstration.  If ERT is requested and a Real-Time Workshop
% Embedded Coder license is not available a error is reported.
%
% model  - Name of model, bdroot, etc.
% fpMode - fixed   : configure for fixed-point
%          floating: configure for floating-point
%          noop    : don't change relevant fixed/float settings
% forGRT - Configure for GRT
  
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:15:26 $
  
  if isempty(overrides)
    overrides = {};
  else
    overrides = eval(overrides);
  end
  if ~iscell(overrides)
    error('The variable ''overrides'' should be a cell of strings');
  end
  
  % Save dirty flag
  
  isDirty = strcmp(get_param(model,'Dirty'),'on');
  
  if ~forGRT && ~slproductinstalled('RTW_Embedded_Coder')
    errMsg = ['Real-Time Workshop Embedded Coder must be installed ',...
              'to configure for ERT code generation.'];
    error(errMsg);
  end
  
  % Get the active configuration set
  
  cs = getActiveConfigSet(model);
  
  % Need to preserve specified overrides in the configuration set
  
  for i = 1 : length(overrides)
    if isValidParam(cs,overrides{i})
      overrideValues{i} = get_param(cs,overrides{i});
    end
  end

  rtwconfiguremodel(model, 'Specified', 'fxpMode', fpMode, 'forGRT', forGRT, ...
                 'optimized', true, 'forDSP', false, 'nonFinites', false);
      
  for i = 1 : length(overrides)
    if isValidParam(cs,overrides{i})
      set_param(cs,overrides{i},overrideValues{i});
    end
  end

  % For demos, do not dirty the model simply for a "canned" configuration change
  if ~isDirty
    set_param(model,'Dirty','off');
  end
  