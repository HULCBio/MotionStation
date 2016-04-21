function [mcdcData,flags,mcdcObjs] = report_mcdc_block(blockInfo,currMcdcCnt)
% MCDC_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 2003 The MathWorks, Inc.

    global gmcdc gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
	
	
    [mcdcObjs,localIdx,localCnt] = cv('MetricGet',blockInfo.cvId, ...
                                        MetricVal.mcdc,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow');

    if isempty(localCnt) | localCnt==0
        mcdcData = [];
        return;
    end

    mcdcData.mcdcIndex = currMcdcCnt + (1:length(mcdcObjs));
    mcdcData.localHits = gmcdc(localIdx+1,:);
    mcdcData.localCnt = localCnt;

    if (mcdcData.localHits(end) == localCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if mcdcData.localHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



