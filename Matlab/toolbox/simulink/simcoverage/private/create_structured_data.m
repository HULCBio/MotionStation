function [cvstruct,sysCvIds] = report_create_structured_data(cvstruct, cvId, metricNames, waitbarH)   

% Copyright 2003 The MathWorks, Inc.

	global gElimFullCov;
	
	% Cyclomatic complexity metric index
	allmetrics = cv_metric_names;
	cycloEnum = allmetrics.MTRC_CYCLCOMPLEX;
	
    % Order the set of coverage IDs
    [sysCvIds,blockCvIds,depths] = cv('DfsOrder',cvId,'ignore',allmetrics.MTRC_SIGRANGE);
    sysCnt = length(sysCvIds);
    blockCnt = length(blockCvIds);
    
    % Return early if there is nothing to report
    if (sysCnt==0)
        sysCvIds = [];
        return;
    end
        
    
    % Variables for the waitbar display
    waitInc = sysCnt+blockCnt;
    waitUpdate = 10;
    waitVal = 0;
    
    % Preallocate the info structure
    metricCnt = length(metricNames);
    metricSysPreAlloc(1:2:(2*metricCnt-1)) = metricNames;
    metricBlkPreAlloc = metricSysPreAlloc;
    
    for i=1:metricCnt
        metricSysPreAlloc{2*i} = cell(1,sysCnt);
        metricBlkPreAlloc{2*i} = cell(1,blockCnt);
    end
    
    cvstruct.system = struct( ...
                        'name',             cell(1,sysCnt), ...
                        'sysNum',           num2cell(1:sysCnt), ...
                        'cvId',             num2cell(sysCvIds), ...
                        'depth',            num2cell(depths), ...
                        'complexity',       cell(1,sysCnt), ...
                        'sysCvId',          cell(1,sysCnt), ...
                        'subsystemCvId',    cell(1,sysCnt), ...
                        'blockIdx',         cell(1,sysCnt), ...
                        'flags',            cell(1,sysCnt), ...
                        metricSysPreAlloc{:});
                        

	if (blockCnt>0)
        cvstruct.block = struct( ...
                            'name',             cell(1,blockCnt), ...
                            'index',            num2cell(1:blockCnt), ...
                            'cvId',             num2cell(blockCvIds), ...
                            'complexity',       cell(1,blockCnt), ...
                            'sysCvId',          cell(1,blockCnt), ...
                            'flags',            cell(1,blockCnt), ...
	                        metricBlkPreAlloc{:});
    end
    
    
    % Each coverage metric will have a list of objects that detail the exact coverage
    % information.  The arrays for storing these objects will be dynamically created
    metricObjs = cell(1,length(metricNames));
    metricObjsCnt = num2cell(zeros(1,length(metricNames)));;       
        
    % ===================================================================================
    % Loop to update the system information
    % ===================================================================================

    removeSystems = zeros(1,sysCnt);
    for i=1:sysCnt
        cvId = sysCvIds(i);
        [name,origin,parent] = cv('get',cvId, ...
                                    '.name', ...
                                    '.origin', ...
                                    '.treeNode.parent');
                                                                        
        [cmplx_ismodule,cmplx_shallow,cmplx_deep] = cv('MetricGet',cvId,cycloEnum, ...
                                '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep');    
        
        if isempty(cmplx_ismodule)
            cmplx_ismodule = 0;
            cmplx_shallow = 0;
            cmplx_deep = 0;
        end 
                                                                      
        children = cv('ChildrenOf',cvId,'ignore',allmetrics.MTRC_SIGRANGE);
        children = children(children~=cvId);
        isLeaf = (cv('get',children,'.treeNode.child') == 0);
        
        cvstruct.system(i).subsystemCvId = children(~isLeaf);
        blockIds = children(isLeaf);
       
        cvstruct.system(i).complexity = struct( 'isModule', cmplx_ismodule, ...
                                                'shallow', cmplx_shallow, ...
                                                'deep', cmplx_deep);
                                                
        if (origin==2)
           cvstruct.system(i).name = ['SF: ' name];
        else
           cvstruct.system(i).name = name;
        end
        cvstruct.system(i).sysCvId = parent;
        if ~isempty(blockIds)
            blkCnt = length(blockIds);
            firstChildIdx = find(blockIds(1)==blockCvIds);
            cvstruct.system(i).blockIdx = (1:blkCnt)+firstChildIdx-1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%
        % Analyze metrics for
        % this system
        flags.fullCoverage = -1;
        flags.noCoverage = -1;
        flags.leafUncov = 0;
        
        noData = 1;
        for j=1:length(metricNames)
            thisMetric =  metricNames{j};
            [data,thisMetricFlags,objs] = feval([thisMetric '_system'],cvstruct.system(i),metricObjsCnt{j});
            eval(['cvstruct.system(i).' thisMetric '= data;']);
            metricObjs{j} = [metricObjs{j} objs];
            metricObjsCnt{j} = metricObjsCnt{j} + length(objs);
            
            % Update the flag values based on this metric
            if ~isempty(thisMetricFlags)
                noData = 0;
                if  (isfield(thisMetricFlags,'fullCoverage')) 
                     if (thisMetricFlags.fullCoverage)
                     	if (flags.fullCoverage == -1)
                     		flags.fullCoverage = 1;
                     		flags.noCoverage = 0;
                     	end
                     else
                     	flags.fullCoverage = 0;
                     end
                end
                    
                if  (isfield(thisMetricFlags,'noCoverage'))
                     if (thisMetricFlags.noCoverage)
                     	if (flags.noCoverage == -1)
                     		flags.noCoverage = 1;
                     		flags.fullCoverage = 0;
                     	end
                     else
                 		flags.noCoverage = 0;
                     end 
                end
                
                if  (isfield(thisMetricFlags,'leafUncov') & ...
                     thisMetricFlags.leafUncov)
                     flags.leafUncov = 1;
                end
            end
        end
        cvstruct.system(i).flags = flags;
        removeSystems(i) = noData;
        if (~isempty(waitbarH))
            waitVal = waitVal+1;
            waitbar(waitVal/waitInc,waitbarH);
        end
    end
  
    % ===================================================================================
    % Loop to update the block information
    % ===================================================================================

    removeBlocks = zeros(1,blockCnt);
    for i=1:blockCnt
        cvId = blockCvIds(i);
        [name,origin,parent] = cv('get',cvId,'.name','.origin','.treeNode.parent');

        [cmplx_ismodule,cmplx_shallow,cmplx_deep] = cv('MetricGet',cvId,cycloEnum, ...
                                '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep');     
                                                                      

        if isempty(cmplx_ismodule)
            cmplx_ismodule = 0;
            cmplx_shallow = 0;
            cmplx_deep = 0;
        end 

        if (origin==2)
           cvstruct.block(i).name = ['SF: ' name];
        else
           cvstruct.block(i).name = name;
        end
        cvstruct.block(i).sysCvId = parent;
        cvstruct.block(i).complexity = struct( 'isModule', cmplx_ismodule, ...
                                                'shallow', cmplx_shallow, ...
                                                'deep', cmplx_deep);
                                                
        
        %%%%%%%%%%%%%%%%%%%%%
        % Analyze metrics for
        % this block
        flags.fullCoverage = -1;
        flags.noCoverage = -1;
        flags.leafUncov = 0;
        
        noData = 1;
        for j=1:length(metricNames)
            thisMetric =  metricNames{j};
            [data,thisMetricFlags,objs] = feval([thisMetric '_block'],cvstruct.block(i),metricObjsCnt{j});
            eval(['cvstruct.block(i).' thisMetric '= data;']);
            metricObjs{j} = [metricObjs{j} objs];
            metricObjsCnt{j} = metricObjsCnt{j} + length(objs);
            
            % Update the flag values based on this metric
            if  (~isempty(thisMetricFlags))
                noData = 0;
                if(isfield(thisMetricFlags,'fullCoverage')) 
                    if (thisMetricFlags.fullCoverage)
                        if (flags.fullCoverage == -1)
                        	flags.fullCoverage = 1;
                        	flags.noCoverage = 0;
                        end
                    else
                        flags.fullCoverage = 0;
                    end
                end

                if (isfield(thisMetricFlags,'noCoverage'))
                     if (thisMetricFlags.noCoverage)
                     	if (flags.noCoverage == -1)
                     		flags.noCoverage = 1;
                     		flags.fullCoverage = 0;
                     	end
                     else
                 		flags.noCoverage = 0;
                     end 
                end
                
                if (isfield(thisMetricFlags,'leafUncov') & ...
                     thisMetricFlags.leafUncov)
                     flags.leafUncov = 1;
                end
            end
                
        end
        removeBlocks(i) = noData;
        cvstruct.block(i).flags = flags;
        if (~isempty(waitbarH))
            waitVal = waitVal+1;
            waitbar(waitVal/waitInc,waitbarH)
        end
    end
    if ~isempty(removeBlocks)
    	removeBlocks = logical(removeBlocks);
        cvstruct.block(removeBlocks) = [];
        ol2new = (1:length(removeBlocks)) - cumsum(removeBlocks);
        
        % Remap the system blockIdx
        for i=1:sysCnt
            cvstruct.system(i).blockIdx(removeBlocks(cvstruct.system(i).blockIdx)) = [];
            cvstruct.system(i).blockIdx = ol2new(cvstruct.system(i).blockIdx);
        end
    end
    
    % ===================================================================================
    % Update the metric specific info
    % ===================================================================================
    for j=1:length(metricNames)
        thisMetric =  metricNames{j};
		if ~isempty(metricObjs{j})
        	cvstruct = feval([thisMetric '_info'],cvstruct,metricObjs{j});
		end
    end
        


    % ===================================================================================
    % Prune the uneeded systems
    % ===================================================================================
    if gElimFullCov
    	fullcovSys = find_full_coverage_systems(cvstruct);
	    removeSystems = logical(removeSystems' | fullcovSys);
	else
	    removeSystems = logical(removeSystems);
	end
	
	[removeSystems,cvstruct] = fix_eml_script_hierarchy(removeSystems,cvstruct);

    cvstruct.system(removeSystems) = [];
	keepSysCvIds = sysCvIds(~removeSystems);
	
	% Remap indices and remove zeros
    for i=1:length(cvstruct.system)
    	cvstruct.system(i).subsystemCvId = intersection(cvstruct.system(i).subsystemCvId,keepSysCvIds);
    end
    

