function createProject_TItarget(target_state, modelInfo, sources, buildOptions)
% CREATEPROJECT -  Creates a CCS(tm) IDE project
%
%   Using the Link for CCS IDE, this function creates a CCS Project File and 
%   populates it with the generated RTW files and other components.
%
% Arguments:
% 	modelInfo    - Struct containing info about model
%   sources      - Cell array containing all relevant source file strings with 
%                  (with path).  
%   buildOptions - Cell array containing build option strings in the following
%                  order: linker, assembler, and compiler.
%   target_state - Structure containing CCS object (handle to IDE) used to 
%                  create/build/load/run CCS projects.  The object is also 
%                  exported to the base Workspace if desired by user.

% $RCSfile: createProject_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/01 16:17:36 $
% Copyright 2001-2004 The MathWorks, Inc.

% name project and build configuration
projectName = fullfile(pwd,[modelInfo.name '.pjt']);
buildConfigName = 'Custom_MW';

% 'callSwitchyard' is called directly to close previous version of 
%     project found in ANY board
try
    callSwitchyard(target_state.ccsObj.ccsversion,[45,target_state.ccsObj.boardnum,target_state.ccsObj.procnum,0,0], projectName);
catch
    % projectName is not open in any board
end

disp('### Creating project in Code Composer Studio(R)');

% show IDE GUI
target_state.ccsObj.visible(1);

% create a new project and set build configuration
target_state.ccsObj.new(projectName,'project');
target_state.ccsObj.new(buildConfigName,'buildcfg');

% modify CCS build options
setBuildOptions(buildOptions,target_state.ccsObj);

% add source files and libraries to CCS project:
for i=1:length(sources),
    if ~isempty(sources{i}),
        [p, f, e]=fileparts(sources{i});
        if ~strcmp([f e], 'ert_main.c'),
            try
                target_state.ccsObj.add(sources{i});
            catch
                l = lasterr;
                if isempty(findstr(l,'already exists')),
                    error(l)
                end
            end
        end
    end
end

if strcmpi(modelInfo.name,'ert'),
    error('"ert" is not allowed as a model name.')
end

% save the project
target_state.ccsObj.save(projectName,'project');

% optionally export CCS object
exportIDEobject_DSPtarget(target_state.ccsObj,modelInfo.name);


%-------------------------------------------------------------------------------
function setBuildOptions(build_options,ccsObj)

% get current build options
curOpts = ccsObj.getbuildopt;

% update linker options
curOpts(1).optstring = build_options{1};
% update compiler options
curOpts(3).optstring = build_options{3};

% set build options for linker, BIOS builder, and compiler
for i=1:3;
    ccsObj.setbuildopt(curOpts(i).name, curOpts(i).optstring);
end

% [EOF] createProject_TItarget.m
