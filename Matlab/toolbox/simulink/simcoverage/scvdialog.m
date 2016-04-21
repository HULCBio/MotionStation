function out = scvdialog(method, varargin),
%SCVDIALOG - Interface between coverage dialog and simulink

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18.2.5 $  $Date: 2004/04/13 00:34:37 $


    switch(method),
    case 'create',
        if check_cv_license==0
            error(['Failed to check out Simulink Verification and Validation license,', ...
                    ' required for model coverage']);
        end

        system = varargin{1};
        modelH = get_param(system,'Handle');
        [frameH, panelH] = i_DialogCreate(system,modelH);
        i_modelsync(system,panelH);
        out = panelH;

    case 'open',
        panelH = varargin{1};
        modelH = panelH.getModelH;
        i_modelsync(modelH,panelH);
        i_openDlg(panelH);

    case 'HtmlOptions'
        panelH = varargin{1};
        i_createHtmlOptions(panelH);
        
    case 'close',
        panelH = varargin{1};
        i_closeDlg(panelH);

    case 'destroy',
        panelH = varargin{1};
        i_destroyDlg(panelH);

    case 'help',
        helpview([docroot '/toolbox/slvnv/slvnv.map'], 'modelcoverage_dialog');

    case 'modelsync',
        modelH = varargin{1};
        panelH = varargin{2};
        i_modelsync(modelH,panelH);

    case 'applyprops',
        modelH = varargin{1};
        panelH = varargin{2};
        i_applyprops(modelH,panelH);

    case 'blockPath',
        blockH = varargin{1};
        out = i_getblockpath(blockH);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [frameH, panelH] = i_DialogCreate(system,modelH)
% Create the Finder dialog by calling the java constructor

% Call Finder constructor
panelH = com.mathworks.toolbox.simulink.simcoverage.simCovDialog.CreateCovDlg(system,modelH);

% Make the Finder visible
%frameH = panelH.getParent;
frameH = panelH;

% Create checkboxes for available metrics
[names,mTable] = cv_metric_names('all');
panelH.new_metric_checkboxes(mTable(:,1),names,mTable(:,5));

% Create checkboxes for coverage options
optionsTable = cv_dialog_options;
panelH.make_options_entries(optionsTable(:,1),optionsTable(:,2));

% Make everything visible
panelH.setVisible(1);
frameH.setVisible(1);
frameH.show;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_openDlg(panelH)
    %frameH = panelH.getParent;
    frameH = panelH;
    frameH.setVisible(1);
    frameH.show;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_closeDlg(panelH)
    %frameH = panelH.getParent;
    frameH = panelH;
    frameH.setVisible(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_destroyDlg(panelH)
    %frameH = panelH.getParent;
    frameH = panelH;
    frameH.dispose;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_modelsync(modelH,panelH)
% Set the control values to the property values in the model
    
    % Checkbox for coverage display on model is visible 
    % based on feature control.
    if slfeature('CoverageDiagramUI')
        panelH.setModelColoringVis(1);
    else
        panelH.setModelColoringVis(0);
    end

    mdlName = get_param(modelH,'Name');
    %frameJObj = panelH.getFrame;
    %frameJObj = panelH;
    %frameJObj.setTitle(['Coverage Settings - ', mdlName]);
    panelH.setTitle(['Coverage Settings - ', mdlName]);

    value = get_param(modelH,'CovPath');
    panelH.setCovPath(value); 

    value = get_param(modelH,'CovSaveName');
    panelH.setCovSaveName(value); 

    value = get_param(modelH,'CovCompData');
    panelH.setCovCompData(value); 

    value = strcmp(get_param(modelH,'CovHtmlReporting'),'on');
    panelH.setCovHtmlReporting(value); 

    value = strcmp(get_param(modelH,'CovNameIncrementing'),'on');
    panelH.setCovNameIncrementing(value); 

    % Get Coverage metric settings string
    try
        settingStr = get_param(modelH,'CovMetricSettings');
        metricNames = cv_metric_names([],settingStr);
        if ~isempty(metricNames)
            panelH.set_tagged_metric_states(metricNames,ones(length(metricNames),1));
        end
        enabledOptionTags = cv_dialog_options('enabledTags',settingStr);
        if ~isempty(enabledOptionTags)
            panelH.set_tagged_options_states(enabledOptionTags,ones(length(enabledOptionTags),1));
        end
        
        % "e" is reserved in the settingStr for disabling the editor (or Model) coverage display
        modelColoringState = ~any(settingStr == 'e');
        panelH.setModelColoring(modelColoringState);
        
    catch,
        % By default turn all metrics on
        metricNames = cv_metric_names('all');
        panelH.set_tagged_metric_states(metricNames,ones(length(metricNames),1));
        optionsTable = cv_dialog_options;
        panelH.set_tagged_options_states(optionsTable(:,2),cat(1,optionsTable{:,5}));
    end

    % Get Coverage metric settings string
    try
        htmlOptions = get_param(get_param(modelH,'Name'),'CovHTMLOptions');
        panelH.setHTMLOptions(htmlOptions);
    catch,
        panelH.setHTMLOptions(' ');
	end
	
    % 9/2001 - Begin
    value = strcmp(get_param(modelH, 'CovSaveCumulativeToWorkspaceVar'), 'on');
    panelH.setSaveCumulativeToWorkspaceVar(value);
    value = strcmp(get_param(modelH, 'CovSaveSingleToWorkspaceVar'), 'on');
    panelH.setSaveSingleToWorkspaceVar(value);
    value = get_param(modelH, 'CovCumulativeVarName');
    panelH.setCumulativeVarName(value);
    value = strcmp(get_param(modelH, 'CovCumulativeReport'), 'on');
    panelH.setCumulativeReport(value);
    value = strcmp(get_param(modelH, 'CovReportOnPause'), 'on');
    panelH.setReportOnPause(value);
    % 9/2001 - End

    value = strcmp(get_param(modelH,'RecordCoverage'),'on');
    panelH.setCovEnabled(value); 
    panelH.updateDlgEnable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  i_applyprops(modelH,panelH)
% Set the the property values in the model based on the widget settings

    set_param(modelH,'CovPath',char(panelH.getCovPath));
    set_param(modelH,'CovSaveName',char(panelH.getCovSaveName));
    set_param(modelH,'CovCompData',char(panelH.getCovCompData));

    if (panelH.getCovHtmlReporting)
        set_param(modelH,'CovHtmlReporting','on');
    else
        set_param(modelH,'CovHtmlReporting','off');
    end

    if (panelH.getCovNameIncrementing)
        set_param(modelH,'CovNameIncrementing','on');
    else
        set_param(modelH,'CovNameIncrementing','off');
    end

    if (panelH.getCovEnabled)
        set_param(modelH,'RecordCoverage','on');
    else
        set_param(modelH,'RecordCoverage','off');
    end

    % Save the metric settings
    enabledMetrics = {};
    metricNames = cv_metric_names('all');
    for metric = metricNames(:)'
        if (panelH.get_tagged_metric_state(metric{1})==1)
            enabledMetrics = [enabledMetrics metric];
        end
    end
    [notUsed,metricSettingStr] = cv_metric_names(enabledMetrics);
    optionsStr = '';
    optionsTable = cv_dialog_options;
    for optionChar = optionsTable(:,2)'
        if (panelH.get_tagged_option_state(optionChar{1})==1)
            optionsStr = [optionsStr optionChar{1}];
        end
    end
    
    % Use "e" to indicate that model coloring is disabled
    modelColoringState = panelH.getModelColoring;
    if ~modelColoringState 
        optionsStr = [optionsStr 'e'];
    end

    try
        set_param(modelH,'CovMetricSettings',[metricSettingStr optionsStr]);
    catch
        % Add the parameter if it doesn't exist
        add_param(get_param(modelH,'Name'),'CovMetricSettings',settingStr);
    end
    
    % Save the HTML options
    htmlOptionsStr = char(panelH.getHTMLOptions);
    try
        set_param(modelH,'CovHTMLOptions',htmlOptionsStr);
    catch
        % Add the parameter if it doesn't exist
        add_param(modelH,'CovHTMLOptions',htmlOptionsStr);
    end
    
    % 9/2001 - Begin
    set_param(modelH, 'CovSaveCumulativeToWorkspaceVar', boolToOnOff(panelH.getSaveCumulativeToWorkspaceVar));
    set_param(modelH, 'CovSaveSingleToWorkspaceVar',     boolToOnOff(panelH.getSaveSingleToWorkspaceVar));
    set_param(modelH, 'CovCumulativeVarName',            char(panelH.getCumulativeVarName));
    set_param(modelH, 'CovCumulativeReport',             boolToOnOff(panelH.getCumulativeReport));
    set_param(modelH, 'CovReportOnPause',                boolToOnOff(panelH.getReportOnPause));
    % 9/2001 - End

function OnOff = boolToOnOff(b)
    if b
        OnOff = 'on';
    else
        OnOff = 'off';
    end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_createHtmlOptions(panelH)

    % WISH change name to cvhtml when done
    optionsTable = cvhtml('optionsTable');
    
    [optCnt,colCnt] = size(optionsTable);
    for i=1:optCnt
        if strcmp(optionsTable{i,1},'>----------')
            panelH.html_option_space;
        else
            panelH.new_html_option(optionsTable{i,1},optionsTable{i,3},optionsTable{i,2},optionsTable{i,4});
        end
    end
    panelH.html_options_done;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = i_getblockpath(blockH)
    disp('Calculating block path!!\n');
    name = get_param(blockH,'Name');
    parent = get_param(blockH,'Parent');
    model = bdroot(parent);

    firstChar = length(model)+1;
    str = [parent '/' name];
    cr = find(str==10);
    str(cr) = char(32);
    if (bdroot(blockH)==blockH)
        out = '/';
    else
    	out = str(firstChar:end);
    end
