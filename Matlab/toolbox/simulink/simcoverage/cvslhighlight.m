function cvslhighlight(method,varargin)
%CVSLHIGHLIGHT - Function to apply and revert specialized block coloring

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/31 19:50:16 $

    switch(lower(method))
    case 'apply'
        apply_color(varargin{:});
    case 'revert'
        model_revert(varargin{:});
    otherwise,
        error('Unkown Method');
    end
    
function apply_color(modelH,blockH,fgColor,bgColor,systemH,screenColor)

    if nargin<6
        systemH = [];
        screenColor = [];
    end
    
    modelColorData = get_param(modelH,'covColorData');
    isDirty = strcmp(get_param(modelH,'dirty'),'on');
    
    % Add a new entry if needed
    if isempty(modelColorData)
        modelColorData = struct('mappedBlks',[],'FGColor',[],'BGColor',[],'systems',[],'screenColors',[]);
    end
    
    if ~isempty(blockH)
        % Filter out linked blocks to prevent warnings
        isLib = is_implicit_linked_blk(blockH);
        blockH(isLib) = [];
        
        % Store the existing highlighting of any blocks 
        % that are not already mapped
        [newBlks,newIdx] = setdiff(blockH,modelColorData.mappedBlks);
        fgcolors = get_param(newBlks,'ForegroundColor');
        bgcolors = get_param(newBlks,'BackgroundColor');
        
        modelColorData.mappedBlks = [modelColorData.mappedBlks ; newBlks(:)];
        if length(newBlks)==1
            if isempty(modelColorData.FGColor)
                modelColorData.FGColor = {fgcolors};
                modelColorData.BGColor = {bgcolors};
            else
                modelColorData.FGColor(end+1) = {fgcolors};
                modelColorData.BGColor(end+1) = {bgcolors};
            end
        else
            modelColorData.FGColor = [modelColorData.FGColor ; fgcolors(:)];
            modelColorData.BGColor = [modelColorData.BGColor ; bgcolors(:)];
        end
       
        % Apply the new colors
        for i=1:length(blockH)
            set_param(blockH(i),'BackgroundColor',bgColor,'ForegroundColor',fgColor);
        end
    end
    
    
    if ~isempty(systemH)
        [newSys,newIdx] = setdiff(systemH,modelColorData.systems);
        screenColors = get_param(newSys,'ScreenColor');
        if ~iscell(screenColors)
            screenColors = {screenColors};
        end

        modelColorData.systems = [modelColorData.systems ; newSys(:)];
        modelColorData.screenColors = [modelColorData.screenColors ; screenColors(:)];
        
        % Apply the new colors
        for i=1:length(systemH)
            set_param(systemH(i),'ScreenColor',screenColor);
        end
    end
    
    
    
    set_param(modelH,'covColorData',modelColorData);

    % Restore the dirty flag if needed
    if ~isDirty
        set_param(modelH,'dirty','off');
    end
    
function model_revert(modelH)    
    
    modelColorData = get_param(modelH,'covColorData');
    if nargin<2
        modelH = get_param(bdroot(gcs),'Handle');
    end
    
    isDirty = strcmp(get_param(modelH,'dirty'),'on');
    
    if isempty(modelColorData)
        return;
    end

    blockH = modelColorData.mappedBlks;
    fgColor = modelColorData.FGColor;
    bgColor = modelColorData.BGColor;
    
    for i=1:length(blockH)
        set_param(blockH(i),'ForegroundColor',fgColor{i},'BackgroundColor',bgColor{i});
    end
    
    systems = modelColorData.systems;
    screenColors = modelColorData.screenColors;

    for i=1:length(systems)
        set_param(systems(i),'ScreenColor',screenColors{i});
    end
    


    set_param(modelH,'covColorData',[]);

    % Restore the dirty flag if needed
    if ~isDirty
        set_param(modelH,'dirty','off');
    end

function out = is_linked_blk(blockH)

    refBlks = get_param(blockH,'ReferenceBlock');
    out = ~strcmp( refBlks, '');

function out = is_implicit_linked_blk(blockH)

    parents = get_param(get_param(blockH,'Parent'),'Handle');
    if iscell(parents)
        parents = [parents{:}];
    end
    
    isModel = (parents == bdroot(blockH(1)));
    out(isModel) = logical(0);
    out(~isModel) = is_linked_blk(parents(~isModel));    
    
    
    

