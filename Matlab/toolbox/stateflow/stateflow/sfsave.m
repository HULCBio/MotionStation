function sfsave(machine, saveAs, interactive)
%SFSAVE Saves a machine.
%        SFSAVE saves the current machine.
%        SFSAVE(  MODEL_HANDLE ) saves the model specified by its handle
%        SFSAVE(  MODEL_HANDLE, 'SAVEASNAME' ) saves the given model with a new name.
%        SFSAVE(  MACHINE_HANDLE ) saves the model corresponding to the specified machine
%        SFSAVE( 'MODEL_NAME' ) saves the specified model.
%        SFSAVE( 'DEFAULTS' ) saves the current environment defaults settings
%        in the defaults file.
%
%        See also SF, SFNEW, SFOPEN, SFCLOSE, SFPRINT, SFEXIT.

%
%	E. Mehran Mestchian
%   Jay R. Torgerson
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.20.2.4 $  $Date: 2004/04/15 01:01:48 $

%
% No args ==> save current model iff it has a machine.
%

  switch nargin,
   case 0,
    currentSys = gcs;
    if (exist(currentSys)~=4) return; end

    modelH = get_param(currentSys,'handle');
    modelHasMachine = sf('find','all','machine.simulinkModel',modelH);
    if ~isempty(modelHasMachine)
      if(~has_license(modelHasMachine))
         return;
      end
      open_system(currentSys);
      eval('save_system(currentSys, currentSys)','errordlg(lasterr)');
    end;
    return;
   case 1,
    modelH = resolve_model_handle(machine);
    if ~isempty(modelH), 
      modelHasMachine = sf('find','all','machine.simulinkModel',modelH);
      if ~isempty(modelHasMachine) & ~has_license(modelHasMachine)
         return;
      end
      eval('save_system(modelH)','errordlg(lasterr)');
    end;  % if empty and no error occurred,
          % defaults were set.
    return;
   case {2,3},
    modelH = resolve_model_handle(machine);
    if isempty(modelH), 
      error('Bad first argument oor system does not exist'); 
   else
      modelHasMachine = sf('find','all','machine.simulinkModel',modelH);
      if ~isempty(modelHasMachine) & ~has_license(modelHasMachine)
         return;
      end
   end
   otherwise, 
    help('sfsave');
    return;
  end;

  %
  % We either have 2 or 3 args at this point. 3 ==> interactive requested
  %
  fileName  = get_param(modelH, 'Filename');
  modelName = get_param(modelH, 'Name');
  
  if iscell(modelName),
	  modelName = modelName{1};
  end;
  
  if iscell(fileName),
	  fileName = fileName{1};
  end;
  
  interactiveSave = nargin > 2 & (~isempty(saveAs) | isempty(fileName));

  %
  % make sure we have a valid saveAs!
  %
  if isempty(saveAs),
    if isempty(fileName),
      saveAs = modelName;
    else,
      saveAs = fileName;
    end;
  end;

  %
  % insure a good extension
  %
  if isempty(regexp(saveAs,'\.mdl$', 'once')),
    saveAs = [saveAs,'.mdl'];
  end;

  %
  % only bring the ui iff interactiveSave == true
  %
  if interactiveSave,
    [f,p] = uiputfile(saveAs, modelName);
  else, 
    f = saveAs;
    p = pwd;
  end;
 
  if (f~=0),
    pwdDir = pwd;
    cd(p);

    % Strip off '.mdl'
    f = regexprep(f,'(.*)\.mdl$', '$1');
    
    try, save_system(modelName, f);
    catch, errordlg(lasterr);
    end;
    cd(pwdDir);
  end;

  
%-------------------------------------------------------------------------------------
function modelH = resolve_model_handle(machine)
%
% Find the correspoding model for machine regardless of it's type
%
	modelH = [];
	switch ml_type(machine),
		case 'string',
			if strcmp(machine, 'defaults'), sfinit('save_defaults'); return;
			else, modelH = find_system('Name', machine);
			end;
		case 'sf_handle',
			modelH = sf('get',machine,'.simulinkModel');
		case 'sl_handle',
			modelH = machine;
		otherwise, error('Bad arg(s) passed to sfsave()');
	end;

%-------------------------------------------------------------------------------------
function hasLicense = has_license(machineId)
   hasLicense = 1;
    if ~sf('License', 'basic', machineId),
       hasLicense = 0;
        sf_demo_disclaimer;
        return;
    end;
