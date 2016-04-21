function errorCount = update_truth_table_for_fcn(fcnId,incremental)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/15 01:01:27 $
    
    errorCount = 0;
    oldChecksum = sf('get',fcnId,'state.truthTable.checksum');
    predicateArray =  sf('get',fcnId,'state.truthTable.predicateArray');
    actionArray =  sf('get',fcnId,'state.truthTable.actionArray');

    if(incremental)
        newChecksum = compute_truth_table_checksum(fcnId, predicateArray,actionArray);
        transitions = sf('TransitionsOf',fcnId);
        % WISH we need a much better checksum mechanism
        if(~isempty(transitions))
            if(isequal(oldChecksum,newChecksum))
                % no change. return early.
                return;    
            end
        end
        % further sanity check
    end
    
    ignoreErrors = 1;
    errorCount = create_truth_table(fcnId, ignoreErrors);
    if(errorCount==0)
        newChecksum = compute_truth_table_checksum(fcnId, predicateArray,actionArray);
        sf('set',fcnId,'state.truthTable.checksum',newChecksum);
    end    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function  checksum = compute_truth_table_checksum(fcnId, predicateArray,  actionArray)
    checksum = [0 0 0 0];
    checksum = md5(checksum,sf('Version','str'));
    allData = sf('DataOf',fcnId);
    autogenData = sf('find',allData,'data.autogen.isAutoCreated',1);
    autogenTempData = sf('find',autogenData,'data.scope','TEMPORARY_DATA');
    for i=1:length(autogenTempData)
        checksum = md5(checksum,data_check_sum(autogenTempData(i)));    
    end
    % Compute checksum for truth table content
    for i = 1:prod(size(predicateArray))
        checksum = md5(checksum,predicateArray{i});
    end
    for i = 1:prod(size(actionArray))
        checksum = md5(checksum,actionArray{i});
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function checksum =  data_check_sum(dataId)
    [dataName,dataSize,dataType,dataScope] =sf('get',dataId...
                                  ,'data.name'...
                                  ,'data.props.array.size'...
                                  ,'data.dataType'...
                                  ,'data.scope');
    checksum = md5(dataName,dataSize,dataType,dataScope);
    