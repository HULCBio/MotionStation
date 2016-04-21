function cv_display_on_model(cvstruct, metricNames, informerUddObj)
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

    global gCumulativeReport;

    % System table template
    testCnt = length(cvstruct.tests);
    if testCnt>1
        if gCumulativeReport
            columnCnt = testCnt;
            totalIdx = testCnt;
        else
        columnCnt = testCnt+1;
        totalIdx = testCnt+1;
        end
    else
        columnCnt = 1;
        totalIdx = 1;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      Structural coverage     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fullCovObjs = [];
    missingCovObjs = [];
    
    if any(strcmp(metricNames,'decision')) || any(strcmp(metricNames,'condition'))
       
        % Loop through each system and itemize coverage
        newSysCnt = length(cvstruct.system);
        for i=1:newSysCnt;
            sysEntry = cvstruct.system(i);
            missingCov = install_informer_text(informerUddObj,sysEntry,cvstruct);
            switch(missingCov)
            case 1,
                 missingCovObjs = [missingCovObjs sysEntry.cvId];
            case 0,
                fullCovObjs = [fullCovObjs sysEntry.cvId];
            end
    
            if cv('get',sysEntry.cvId,'.origin')==2
                try,
                    sfId = cv('get',sysEntry.cvId,'.handle');
                    if (sf('get',sfId,'.isa')==sf('get','default','state.isa'))
                        is_a_truth_table = sf('get',sfId,'.truthTable.isTruthTable');
                    else
                        is_a_truth_table = 0;
                    end
                catch   
                    is_a_truth_table = 0;
                end
            else
                is_a_truth_table = 0;
            end
    
            if ~is_a_truth_table
                for blockI = sysEntry.blockIdx(:)'
                    blkEntry = cvstruct.block(blockI);
                    missingCov = install_informer_text(informerUddObj,blkEntry,cvstruct);
                    switch(missingCov)
                    case 1,
                        missingCovObjs = [missingCovObjs blkEntry.cvId];
                    case 0,
                        fullCovObjs = [fullCovObjs blkEntry.cvId];
                    end
                end
            end
        end

        coverage_highlight_diagram(cvstruct,fullCovObjs,missingCovObjs);
    end
                  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %        Signal ranges         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if any(strcmp(metricNames,'sigrange'))
        modelH = get_param(cvstruct.model.name,'Handle');
        covdata = cvstruct.allCvData{totalIdx};
        map_signal_ranges(modelH,covdata,informerUddObj);
    end



function coverage_highlight_diagram(cvstruct,fullCovObjs,missingCovObjs)

    persistent sfFullCovStyle sfNoCovStyle sfMissingCovStyle;
    
    % Colors for stateflow objects
    sfRed =[0.9 0 0];
    sfGreen = [.3 .7 .3];
    sfGray = 0.7*[1 1 1];
    lightGray = 0.92*[1 1 1];
    
    % Style objects
    if isempty(sfFullCovStyle) || ~sf('ishandle',sfFullCovStyle)
        sfFullCovStyle = sf('new','style');
        sf('set', sfFullCovStyle,  ...
                    'style.name',                         'Full coverage', ...
                    'style.blockEdgeColor',         sfGreen, ...
                    'style.wireColor',              sfGreen, ...
                    'style.fontColor',              sfGreen, ...
                    'style.bgColor',                lightGray);
    end
    
    if isempty(sfNoCovStyle) || ~sf('ishandle',sfNoCovStyle)
        sfNoCovStyle = sf('new','style');
        sf('set', sfNoCovStyle,  ...
                    'style.name',                         'No coverage', ...
                    'style.blockEdgeColor',         sfGray, ...
                    'style.wireColor',              sfGray, ...
                    'style.fontColor',              sfGray, ...
                    'style.bgColor',                lightGray);
    end
    
    if isempty(sfMissingCovStyle) || ~sf('ishandle',sfMissingCovStyle)
        sfMissingCovStyle = sf('new','style');
        sf('set', sfMissingCovStyle,  ...
                    'style.name',                         'Missing coverage', ...
                    'style.blockEdgeColor',         sfRed, ...
                    'style.wireColor',              sfRed, ...
                    'style.fontColor',              sfRed, ...
                    'style.bgColor',                lightGray);
    end
    
    [slMissing,sfMissing] = convert_to_handle_vect(missingCovObjs);
    [slCovered,sfCovered] = convert_to_handle_vect(fullCovObjs);
    
    hasStateflow = ~isempty([sfMissing ; sfCovered]);
    
    % Build a list of all states and transitions
    if hasStateflow
        sfChartIds = sf('get',[sfMissing ; sfCovered],'chart.id');
        allSfStates = [];
        for chrt = sfChartIds(:)'
            allSfStates = [allSfStates sf('SubstatesIn', chrt)];
        end
        allSfTrans = [];
        for st = allSfStates(:)'
            allSfTrans = [allSfTrans sf('TransitionsOf', st)];
        end
        noCovTrans = setdiff(allSfTrans,[sfMissing ; sfCovered]);
        noCovStates = setdiff(allSfStates,[sfMissing ; sfCovered]);
    end
        
    modelH = get_param(cvstruct.model.name,'Handle');
    allBlocks = find_system(modelH,'FollowLinks','on','LookUnderMasks','on','type','block');
    nocovBlocks = setdiff(allBlocks,slMissing);
    nocovBlocks = setdiff(nocovBlocks,slCovered);
    slMissing = setdiff(slMissing,modelH);
    slCovered = setdiff(slCovered,modelH);
    
    % For efficiency only apply screen colors to a system that has
    % at least one block with coverage highlighting
    slSystems = get_param(get_param([slMissing ; slCovered],'Parent'),'Handle');
    if iscell(slSystems)
        slSystems = unique([slSystems{:}]);
    end

    % Simulink systems
    if ~isempty(slSystems)
        cvslhighlight('apply',modelH,[],[],[],slSystems,'[0.92, 0.92, 0.92]');
    end

    
    % Cache warning state and supress further warnings
    warnState = warning('query');
    warning('off','all');
    
    % Fully covered blocks
    if ~isempty(slCovered)
        cvslhighlight('apply',modelH,slCovered,'black','[0.803922, 0.952941, 0.811765]');
    end
    if ~isempty(sfCovered)
        sf('set',sfCovered,'.altStyle',sfFullCovStyle);
    end
    
    % Blocks that don't have coverage
    if (hasStateflow)
        sf('set',[noCovTrans(:) ; noCovStates(:)],'.altStyle',sfNoCovStyle);
    end
    
    % Partially covered blocks
    if ~isempty(slMissing)
        cvslhighlight('apply',modelH,slMissing,'black','[0.972549, 0.823529, 0.803922]');
    end
    if ~isempty(sfMissing)
        sf('set',sfMissing,'.altStyle',sfMissingCovStyle);
    end


    % Redraw all the charts
    if hasStateflow
        machineId = sf('find','all','machine.name',cvstruct.model.name);
        sf('Redraw',machineId);
    end
        
    % Restore the warning state
    warning(warnState);
    
    
function [slVect,sfIds] = convert_to_handle_vect(idVect)

    slcvIds = cv('find',idVect,'slsfobj.origin',1);
    sfcvIds = cv('find',idVect,'slsfobj.origin',2);
    slVect = cv('get',slcvIds,'slsfobj.handle');
    sfIds = cv('get',sfcvIds,'slsfobj.handle');

function sf_diagram_highlight(hVect,RGBcolor)

    if isempty(hVect)
        return;
    end

    lineVect = findobj(hVect,'Type','line');
    rectVect = findobj(hVect,'Type','rectangle');
    textVect = findobj(hVect,'Type','text');
    
    set(lineVect,'Color',RGBcolor);
    set(rectVect,'EdgeColor',RGBcolor);
    set(textVect,'Color',RGBcolor);
    
