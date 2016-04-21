function mouseevent(sisodb,EventName)
%MOUSEEVENT  Processes mouse events.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 04:59:38 $

% REVISIT: used only for WBM, waiting for local events...
if strcmp(EventName,'wbm')  
    % Pass event down to children and give right of way if any child is taker
    Children = find(sisodb,'-depth',1);  % warning: 1st entry = sisodb
    for ct=2:length(Children)
        if mouseevent(Children(ct),EventName)
            return
        end
    end
    
    % Window button motion
    if ~strcmp(get(sisodb.Figure,'Pointer'),'arrow')
        set(sisodb.Figure,'Pointer','arrow');
    end
    
    % Customize status if above loop configuration diagram
    HG = sisodb.HG;
    CP = get(HG.LoopConfigFrame.ConfigAxes,'CurrentPoint');
    if CP(1,3)==1,
        % Above loop configuration diagram: temporarily override status
        sisodb.EventManager.poststatus(...
            sprintf('Click on G or H to see the system data.\nClick on C or F to edit the compensators.'));
    else
        sisodb.EventManager.poststatus(sisodb.EventManager.Status);
    end
end
