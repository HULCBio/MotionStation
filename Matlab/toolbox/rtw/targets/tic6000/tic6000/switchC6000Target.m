function switchC6000Target(sys, newSysTargetFile)
%SWITCHC6000TARGET
% Sets System Target File on the specified model to the desired file,
% preserving C6000-specific RTW Options.
% newSysTargetFile can be 'ti_c6000.tlc' or 'ti_c6000_ert.tlc'.
% If you use the Configuration dialog to change the system target file,
% all C6000-specific options are set to their default values. 
% Use this function to switch between the ERT-based and GRT-based 
% targets while preserving the C6000 options.
%
% e.g.
%  switchC6000Target(gcs,'ti_c6000_ert.tlc');

% Copyright 2003 The MathWorks, Inc.

cs = getActiveConfigSet(sys);

oldSysTargetFile = get_param(cs,'SystemTargetFile');
if strcmp(oldSysTargetFile,newSysTargetFile),
    disp('The model is already configured to use this system target file.')
    return;
end
if ~(strcmp(newSysTargetFile,'ti_c6000.tlc') || ...
        strcmp(newSysTargetFile,'ti_c6000_ert.tlc') ),
    error('This utility only supports TI C6000 system target files.')
end

if ~(strcmp(oldSysTargetFile,'ti_c6000.tlc') || ...
        strcmp(oldSysTargetFile,'ti_c6000_ert.tlc') ),
    
    error('This utility only supports switching between TI C6000 system target files.')

end


% get c6000 option info
opts = c6000_getRtwOptions({});

% Convert to cell array
optNames = {};
for k = 1:length(opts),
    if ~isempty(opts(k).tlcvariable),
        optNames{end+1} = opts(k).tlcvariable;
    end
end

% Remember current values
for k = 1:length(optNames)
    optValues{k} = get_param(cs,optNames{k});
end

% Switch target
settings.TemplateMakefile = strrep(newSysTargetFile,'.tlc','.tmf');
settings.MakeCommand = 'make_rtw';
settings.Description = '';
cs.switchTarget(newSysTargetFile,settings);

% Write saved values
for k = 1:length(optNames)
    set_param(cs,optNames{k},optValues{k});
end

