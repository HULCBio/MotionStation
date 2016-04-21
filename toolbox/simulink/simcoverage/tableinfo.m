function varargout = tableinfo(data,block,ignoreDecendents,cvId)
%TABLEINFO - Decision coverage information for a model object
%
%   COVERAGE = TABLEINFO(DATA, BLOCK) Find the table coverage
%   for BLOCK within the cvdata coverage object DATA.  BLOCK can be
%   the full path to a simulink block or model, or the handle to a 
%   simulink block or model. COVERAGE is returned as a 2 element 
%   vector: [covered_intervals total_intervals].  If information 
%   about BLOCK is not part of DATA then COVERAGE is empty.
%  
%   COVERAGE = TABLEINFO(DATA, BLOCK, IGNORE_DECENDENTS) 
%   Find the table coverage for BLOCK and ignore the coverage in 
%   decendent objects if IGNORE_DECENDENTS is true.
%  
%   [COVERAGE,EXECCOUNTS] = TABLEINFO(DATA, BLOCK) Find the coverage 
%   and produce an array containing the execution counts of each 
%   interpolation interval. EXECCOUNTS will have the same number of 
%   dimensions as the lookup table in BLOCK, but each dimension will 
%   be larger by one to permit logging of execution outside the
%   range of break points.
%  
%   [COVERAGE,EXECCOUNTS,BRKEQUALITY] = TABLEINFO(DATA, BLOCK) Produce
%   the counts where a break value tested with equality, BRKEQUALITY. 
%   The cell array BRKEQUALITY contains a vector of equality counts for 
%   each table dimension.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.2.4 $  $Date: 2004/04/15 00:38:51 $

    if check_cv_license==0
        error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

    persistent tblEnum;
    
    if isempty(tblEnum)
        tblEnum =  cv('Private','cv_metric_names','tableExec');
    end
 
    if nargin<2,
        error('TABLEINFO requires two input arguments');
    end

    if nargin<3 | isempty(ignoreDecendents)
        ignoreDecendents = 0;
    end

    if ~isa(data,'cvdata')
        error('First argument must be a cvdata object');
    end

    rootId = data.rootID;
    dataMat = data.metrics.tableExec;
    if isempty(block) 
        if nargin>3
            blockCvId = cvId;
        else
            error('Block must be nonempty');
        end
    else
        blockCvId = find_block_cv_id(rootId,block);
        if ischar(blockCvId)
            error(blockCvId);
        end
    end
    
    if blockCvId==0,
        varargout{1} = [];
        if nargout>1
            varargout{2} = [];
        end
        return
    end
    
    [totalCnt,totalIdx,localCnt,localIdx] = cv('MetricGet',blockCvId,tblEnum, ...
                                               '.dataCnt.deep','.dataIdx.deep','.dataCnt.shallow','.dataIdx.shallow');
    if isempty(totalCnt)
        totalIdx = -1;
        localIdx = -1;
        totalCnt = 0;
        localCnt = 0;
    end
    
    if ignoreDecendents
        if localIdx>=0
            hits = dataMat(localIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits localCnt];
    else
        if totalIdx>=0
            hits = dataMat(totalIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits totalCnt];
    end


    if nargout>1,
        tables = cv('MetricGet', blockCvId, tblEnum, '.baseObjs');
            
        if length(tables)==1
            [brkDims,offset] = cv('get',tables,'table.dimBrkSizes','table.dataBaseIdx.intervalExec'); 
            intervalCnt = prod(brkDims+1);
            rawData = dataMat(offset+(1:intervalCnt));
            if length(brkDims)>1
                varargout{2} = reshape(rawData,brkDims+1);
            else
                varargout{2} = rawData;
            end
            if (nargout >2)
                brkEqOffset = cv('get',tables,'table.dataBaseIdx.brkPtEquality');
                rawData = dataMat(brkEqOffset+(1:sum(brkDims)));
                base = 0;
                for i=1:length(brkDims)
                    eqOut{i} = rawData(base+(1:brkDims(i)));
                    base = base + brkDims(i);
                end
                varargout{3} = eqOut;
            end 
        else
            if isempty(tables)
                varargout{2} = [];
                if (nargout >2)
                    varargout{3} = [];
                end
            else

                % WISH do something here
            end
        end
    end

    
         



