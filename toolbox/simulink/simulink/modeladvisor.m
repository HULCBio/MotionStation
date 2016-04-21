function modeladvisor(system)
% MODELADVISOR Using the Model Advisor Tool, you can quickly
% configure a model for code generation, and identify aspects of your
% model that impede Real-Time Workshop Embedded Coder deployment or limit 
% generated code efficiency.
%
%
% Usage:  Run the Model Advisor on a desired model or subsystem.
%
% >> modeladvisor('model')        % Entire model
% >> modeladvisor('help')         % Show help for Model Advisor Tool.
%
%
 
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2004/03/26 13:29:51 $

cmdPath = [matlabroot filesep 'toolbox' filesep 'simulink' filesep 'simulink' filesep 'ModelAssistant'];

if nargin == 0
   helpview([docroot '/toolbox/rtw/rtw_ug/rtw_ug.map'],'modeladvisordoc');
   return
end

if strcmpi(system,'help')
    helpview([docroot '/toolbox/rtw/rtw_ug/rtw_ug.map'],'modeladvisordoc');
else
    addpath(cmdPath);
    open_system(system);
    % if model hasn't been open yet, get_param('model') won't work.
    if isLibrary(system)
        error('You are using Model Advisor on a library.');
    end        
    try
        if ~usejava('swing')
            error('This tool requires Java to run.');
        end

        % open system if it's not opened yet.
        try
            get_param(system, 'handle');
        catch
            open_system(system);
        end

        % clean up attic for new start
        if ~strcmp(HTMLattic('AtticData', 'NOBROWSER'),'on')
            HTMLattic('clean');
        else
            HTMLattic('clean');
            HTMLattic('AtticData', 'NOBROWSER','on');
        end

        % record command root directory
        cmdRoot = cmdPath;
        HTMLattic('AtticData', 'cmdRoot', cmdRoot);

        %% use space to replace carriage return
        %model = strrep(model, sprintf('\n'), ' ');
        HTMLattic('AtticData', 'model', system);
        createStartInSystemTemplate;

        % addpath for fixpt detective utility
        addpath([cmdRoot filesep 'fixpt']);

        HTMLattic('AtticData', 'Browser', 'java'); % use new java browser
        HTMLattic('AtticData', 'ShowFullName', 1); % show full name of objects

        HTMLattic('AtticData', 'model', system);
        
        % main page to hold frames
        WorkDir = getModelAssistantWorkDir;
        HTMLattic('AtticData', 'DiagnoseStartPage',  [WorkDir filesep 'model_diagnose.html']);

        if exist(HTMLattic('AtticData', 'DiagnoseStartPage'), 'file')
            if rtwprivate('cmpTimeFlag', HTMLattic('AtticData', 'DiagnoseStartPage'), which(getfullname(bdroot(system)))) > 0
                % 1 means DiagnoseStartPage earlier than model file, 2 means DiagnoseStartPage doesn't exist.
                warndlg('WARNING: The model appears to be newer than the report. Consider running the report again.');
            end
            % create new page if not exists, otherwise reload last time page.
            createDiagnoseStartPage(false);
        else
            createDiagnoseStartPage(true, 'FirstTime'); % create default page
        end
        if nargin==1
            % show start page
            browser(HTMLattic('AtticData', 'DiagnoseStartPage'));
        end
    catch
        error(lasterr);
        usage;
    end

end



% ====================================================================
% SUBFUNCTIONS
% ====================================================================
function output = isLibrary(system)
system = bdroot(system);
fp = get_param(system, 'ObjectParameters');
if isfield(fp, 'BlockDiagramType')
    if strcmpi(get_param(system, 'BlockDiagramType'), 'library')
        output = 1;
    else
        output = 0;
    end
else
    % some libraries don't this field.
    output = 1;
end

function createStartInSystemTemplate
model = HTMLattic('AtticData', 'model');
StartInSystemTemplate = ['<h3> Start in system: ' getfullname(model) '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'];
StartInSystemTemplate = [StartInSystemTemplate '</h3>'];
HTMLattic('AtticData', 'StartInSystemTemplate', StartInSystemTemplate);