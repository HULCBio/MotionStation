function accelbuild(varargin)
%ACCELBUILD Build the Accelerator MEX-file for a model.
%   This is done automatically as part of starting an accelerated
%   simulation, but can be done programmatically using this function.
%
%ACCELBUILD('MODELNAME',OPTIONS)
%   OPTIONS: OPT_OPTS=-g
%      Used to disable optimizations and add debugging symbols to
%      the generated mex file. For example to build the f14 demo model for
%      debugging:
%        accelbuild('f14','OPT_OPTS=-g');
%
%      If an optimized accelerator MEX-file for your model already exists and
%      is up to date then you have to delete the MEX-file before running 
%      accelbuild with OPT_OPTS=-g. To do this:
%        1) Stop the simulation. You cannot delete the MEX-file if it is in use.
%        2) delete(['modelname_acc.',mexext]);  
%             e.g. delete('f14_acc.dll');
%        3) accelbuild('modelname','OPT_OPTS=-g');
%             e.g. accelbuild('f14','OPT_OPTS=-g');
%
  
%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

  % Get the model name
  if nargin > 0
    modelName = varargin{1};
  else
    modelName = bdroot;
    if isempty(modelName)
      error('Unable to obtain current model name.');
    end
  end

  openModels = find_system('type','block_diagram');
  modelOpen = 0;
  for i=1:length(openModels)
    mdl = openModels{i};
    if strcmp(mdl,modelName)
      modelOpen = 1;
      break;
    end
  end
  if ~modelOpen
    try
      load_system(modelName);
    catch
      error(lasterr);
      return;
    end
  end
  dirty=get_param(modelName,'dirty');
  if nargin > 1
    savedAccelMakeCmd = get_param(modelName,'AccelMakeCommand');
    set_param(modelName,'AccelMakeCommand', ...
			[savedAccelMakeCmd, ' ', varargin{2:end}])
  end
  try
    set_param(modelName,'simulationcommand','accelbuild');
  catch
    error(lasterr);
  end
  if nargin > 1
    set_param(modelName,'AccelMakeCommand', savedAccelMakeCmd);
  end
  set_param(modelName,'dirty',dirty);
  
%endfunction accelbuild
