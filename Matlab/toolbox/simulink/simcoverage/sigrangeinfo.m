function [mins,maxs] = sigrangeinfo(covdata,block,portIdx)
%SIGRANGEINFO - Signal ranges for a model object
%
%   [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK) Find the signal ranges
%   for BLOCK within the cvdata coverage object DATA.  If the
%   block has multiple outputs they are concatenated together
%   and MIN and MAX will be vectors.
%
%   The BLOCK parameter that specifies the model object can take 
%   the following forms:
%   
%       BlockPath           - Full path to a Simulink block or model
%       BlockHandle         - Simulink block or model handle
%       SimulinkObj         - Simulink object API handle.
%       StateflowID         - Stateflow ID (Should be from a singly 
%                             instantiated chart.)
%       StateflowObj        - Stateflow object API handle. (Should be  
%                             from a singly instantiated chart.)
%      {BlockPath, sfID}    - Cell array with the path to a Stateflow block
%                             and the ID of an object contained in that 
%                             chart instance.
%      {BlockPath, sfObj}   - Path to a Stateflow block and a Stateflow 
%                             object API handle contained in that chart.
%      [BlockHandle sfID]   - Array with a Stateflow block handle and the 
%                             ID of an object contained in that chart 
%                             instance.
%                            
%   [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK,PORTIDX) Limit the signal
%   ranges reported to the PORTIDX output port number for the Simulink
%   block BLOCK.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/15 00:37:53 $



    persistent srEnum;
    
    mins = [];
    maxs = [];
    
    if isempty(srEnum)
        srEnum =  cv('Private','cv_metric_names','sigrange');
    end

    sigrangerIsa = cv('get','default','sigranger.isa');
    rootId = covdata.rootID;
    dataMat = covdata.metrics.sigrange;
    [blockCvId,sfPortEquiv] = find_block_cv_id(rootId,block);
    if ischar(blockCvId)
        error(blockCvId);
    end

    if nargin<3 | isempty(portIdx)
        if sfPortEquiv>=0
            portIdx = sfPortEquiv;
        else
            portIdx = [];
        end
    end
    
    if blockCvId==0
        return;
    end
    
    if (cv('get',blockCvId,'.isa') ~= cv('get','default','sigranger.isa'))
        [blockCvId,cvIsa] = cv('MetricGet',blockCvId, srEnum,'.id','.isa');
        if (isempty(blockCvId) || blockCvId==0 || cvIsa~=sigrangerIsa)
            return;
        end
    end    
    
    [baseIdx,allWidths] = cv('get',blockCvId,'.cov.baseIdx','.cov.allWidths');
    
    if isempty(portIdx)
        lngth = sum(allWidths);
        mins = dataMat(baseIdx + (1:2:(2*lngth)));
        maxs = dataMat(baseIdx + (2:2:(2*lngth)));
    else
        lngth = allWidths(portIdx);
        if portIdx==1
            mins = dataMat(baseIdx + (1:2:(2*lngth)));
            maxs = dataMat(baseIdx + (2:2:(2*lngth)));
        else
            startIdx = baseIdx + [0 2*cumsum(allWidths)];
            start = startIdx(portIdx);
            mins = dataMat(start + (1:2:(2*lngth)));
            maxs = dataMat(start + (2:2:(2*lngth)));
        end
    end
        
        
    
    