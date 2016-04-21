function [tableData,flags,tableObjs] = report_tableexec_system(sysEntry,currTableCnt)
% TABLEEXEC_SYSTEM - Synthesize look-up table coverage data
% for a non-leaf model object.

% Copyright 2003 The MathWorks, Inc.

    global gtableExec gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
    
    [tableObjs,localIdx,localCnt,totalIdx,totalCnt] = cv('MetricGet',sysEntry.cvId, ...
                                        MetricVal.tableExec,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow', ...
                                        '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt)
        localIdx = -1;
        totalIdx = -1;
        totalCnt = 0;
        localCnt = 0;
    end
    
    if totalCnt==0
        tableData = [];
        return;
    end
    
    tableData.tableIdx = currTableCnt + (1:length(tableObjs));
    tableData.localCnt = localCnt;
    if localIdx==-1
        tableData.localHits=[];
    else
        tableData.localHits = gtableExec.rawData(localIdx+1,:);
    end
    tableData.totalHits = gtableExec.rawData(totalIdx+1,:);
    tableData.totalCnt = totalCnt;
   
    if (tableData.totalHits == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(tableData.localHits) & (tableData.localHits(end) ~= localCnt)) 
            flags.leafUncov = 1;
        else    
            flags.leafUncov = 0;
        end        
        
        if tableData.totalHits==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end

    
    
