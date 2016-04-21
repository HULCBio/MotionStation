function [sfNames] = rtwmaputil(modelName)
% RTWMAPUTIL supports globalmaplib.tlc for mapping Real-Time
% Workshop data structures.
%
% rtwmaputil('model_name')

% April 15, 1999
% Copyright 1994-2002 The MathWorks, Inc.
%
% $RCSfile: rtwmaputil.m,v $
% $Revision: 1.11 $
% $Date: 2002/04/10 17:53:04 $

% get Stateflow machine handle

% create an initial string matrix
sfNames = ['machine parented'; 'data            '];

[mf, mexf] = inmem;
sfIsHere = any(strcmp(mexf,'sf'));
if(~sfIsHere)
    return;
end

machineId = sf('find','all','machine.name',modelName);

% No Stateflow in model
if isempty(machineId)
  return;
end

% exported data
ids = sf('find', sf('DataOf', machineId), '.scope', 'EXPORTED_DATA');
sfNames = stash(sfNames, ids, 'Exported');

% imported data
ids = sf('find', sf('DataOf', machineId), '.scope', 'IMPORTED_DATA');
sfNames = stash(sfNames, ids, 'Imported');


% create a nice string matrix to pass back to TLC
function sfNames = stash(sfNames, ids, type)
for idx = 1:length(ids)
  data = ids(idx);
  [dataName,dataSizeArray]= sf('get',data,'data.name','data.parsedInfo.array.size');
  dataType = sf('CoderDataType',data);	
  if(strcmp(dataType,'fixpt'))
    dataType = sf('FixPtProps',data);
  end
    
  if(length(dataSizeArray)<2)
	 sfNames = sf('Private','strrows',sfNames,dataName);
  	 sfNames = sf('Private','strrows',sfNames,type);
     sfNames = sf('Private','strrows',sfNames,dataType);
     if(length(dataSizeArray)==0)
		dataSize = '1';
     else
        dataSize = sprintf('%d',dataSizeArray(1));
     end
     sfNames = sf('Private','strrows',sfNames,dataSize);
  else
     % skip matrix data for now as SF matrix data is stored row-wise
     % and not column-wise
  end
end
