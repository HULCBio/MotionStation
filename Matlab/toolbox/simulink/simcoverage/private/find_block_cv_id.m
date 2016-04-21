function [blockCvId,portIdx] = find_block_cv_id(rootId,block)
%FIND_BLOCK_CV_ID - Find the coverage object corresponding 
% to a model object. This is a critical utility function that
% is used by the command line APIs to the coverage tool
%
%  The BLOCK parameter specifies the model object that is analyzed. It
%  can take the following forms:
%  
%      BlockPath           - Full path to a Simulink block or model
%      BlockHandle         - Simulink block or model handle
%      SimulinkObj         - Simulink object API handle.
%      StateflowID         - Stateflow ID (Should be from a singly 
%                            instantiated chart.)
%      StateflowObj        - Stateflow object API handle. (Should be  
%                            from a singly instantiated chart.)
%     {BlockPath, sfID}    - Cell array with the path to a Stateflow block
%                            and the ID of an object contained in that 
%                            chart instance.
%     {BlockPath, sfObj}   - Path to a Stateflow block and a Stateflow 
%                            object API handle contained in that chart.
%     [BlockHandle sfID]   - Array with a Stateflow block handle and the 
%                            ID of an object contained in that chart 
%                            instance.
%                            
%  If successful, the first output argument is the integer ID for the coverage
%  tool.  Otherwise it is an error string.
%  
%  If two output arguments are specified and the target object is Stateflow
%  data object then the portIdx used by signal range coverage is returned.

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:37:29 $

    % Determine the calling syntax and trap basic errors
    
    persistent sfIsa;
    
    if isempty(sfIsa)
        sfIsa.state = sf('get','default','state.isa');
        sfIsa.trans = sf('get','default','transition.isa');
        sfIsa.chart = sf('get','default','chart.isa');
        sfIsa.data = sf('get','default','data.isa');
    end

    blockH = [];
    sfId = [];
    blockPath = '';
    errormsg = '';
    portIdx = -1;
    switch(class(block)),
    case 'char'
        blockPath = block;

    case 'cell'
        if length(block)>2
            errormsg = 'The BLOCK parameter should be 1 or 2 elements';
        end

        % First element if the instance
        switch(class(block{1})),
        case 'char'
            blockPath = block{1};
        case 'double'
            if floor(block)==block
                sfId = block{1};
            else
                blockH = block{1};
            end
        otherwise
            if strncmp(class(block{1}),'Simulink.',9)
                blockH = block{1}.Handle;
            elseif strncmp(class(block{1}),'Stateflow.',10)
                sfId = block{1}.Id;
            else
                errormsg = 'Element 1 of the BLOCK parameter should be char or double';
            end
        end
        
        if length(block)>1
            switch(class(block{1})),
            case 'double'
                if ~block{2}~=floor(block{2})
                    errormsg = 'Element 2 of the BLOCK parameter should statflow Id or handle';
                else
                    sfId = block{2};
                end
            otherwise,
                if strncmp(class(block{2}),'Stateflow.',10)
                    sfId = block{2}.Id;
                else
                    errormsg = 'Element 2 of the BLOCK parameter should statflow Id or handle';
                end
            end
        end
        
    case 'double'
        switch(length(block))
        case 1,
            if floor(block)==block
                sfId = block;
            else
                blockH = block(1);
            end
        case 2,
            blockH = block(1);
            if floor(block(2))~=block(2)
                errormsg = 'Element 2 of the BLOCK parameter should be integer';
            end
            sfId = block(2);
        otherwise
            errormsg = 'The BLOCK parameter should be 1 or 2 elements';
        end
    otherwise,
        if strncmp(class(block),'Simulink.',9)
            blockH = block.Handle;
        elseif strncmp(class(block),'Stateflow.',10)
            sfId = block.Id;
        else
            errormsg = 'The BLOCK parameter is the wrong type';
        end
    end
    
    if ~isempty(errormsg)
        blockCvId = errormsg;
        return;
    end
    
    % Verify that handles are valid and unique
    if ~isempty(sfId)
        if ~sf('ishandle',sfId)
            errormsg = ['The BLOCK parameter Statflow ID (#' sfId ') is invalid'];
        end
        sfClass = sf('get',sfId,'.isa');
        
        switch(sfClass)
        case sfIsa.chart,
            sfChartId = sfId;
        case {sfIsa.state sfIsa.trans},
            sfChartId = sf('get',sfId,'.chart');
        case sfIsa.data,
            [dataParent,dataNumber] = sf('get',sfId,'.linkNode.parent','data.number');
            parentClass = sf('get',dataParent,'.isa');
            switch(parentClass)
            case sfIsa.chart,
                sfChartId = dataParent;
            case sfIsa.state,
                sfChartId = sf('get',dataParent,'.chart');
            otherwise,
                errormsg = 'The BLOCK parameter Statflow object cannot be machine parented data';
            end
            
            % Data objects need to be resolved to an equivalent port index:
            if (dataNumber==0)
                machineId = sf('get',sfChartId,'chart.machine');
                sf('Private','autobuild',machineId,'sfun','parse','no','no',sfChartId);
                dataNumber = sf('get',sfId,'data.number');
            end
            portIdx = dataNumber+1;   
            
        otherwise
            errormsg = 'The BLOCK parameter Statflow object should be a state, transition, chart, or data';
        end
    end
    
    if ~isempty(blockPath)
        try,
            blockH = get_param(blockPath,'Handle');
        catch,
            errormsg = ['The BLOCK parameter path ("' blockPath '") is invalid'];
        end
    else
        if ~isempty(blockH) & ~ishandle(blockH)
            errormsg = ['The Simulink handle in the BLOCK parameter is invalid'];
        end
    end
    
    if ~isempty(errormsg)
        blockCvId = errormsg;
        return;
    end
    
    if isempty(blockH)    
        instances = sf('get',sfChartId,'.instances');
        blockH = sf('get',instances(1),'.simulinkBlock');
        if length(instances)>1
            warning(['Potential ambiguity, Stateflow chart #' sfChartId 'is multiply instantiated']); 
        end       
    end    

    % Get the coverage id from cv
    blockCvId = cv('FindBlockId',rootId,blockH);
    if blockCvId == 0,
        errormsg = ['The Simulink handle in the BLOCK parameter does not exist in the coverage data'];
        blockCvId = errormsg;
        return;
    end
    

    % Find the stateflow object
    if ~isempty(sfId)
        sfChartObjs = cv('DecendentsOf',blockCvId);
        if portIdx>=0
            blockCvId = cv('find',sfChartObjs,'slsfobj.handle',sfChartId);
        else
            blockCvId = cv('find',sfChartObjs,'slsfobj.handle',sfId);
        end
    end

