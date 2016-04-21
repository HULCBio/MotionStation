function str = code_data_initialization(dataNumber, varNameFromIR,dataTypeOfVar)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.34.2.1.4.1 $  $Date: 2004/04/13 03:12:38 $

	% This function is called from IR module constrcution
	
	global gDataInfo gMachineInfo  gTargetInfo
	

	data = gDataInfo.dataList(dataNumber+1);
   dataParent = sf('get',data,'data.linkNode.parent');
	dataShortName = sf('get',data,'data.name');
	dataSizeArray = gDataInfo.dataSizeArrays{dataNumber+1};
	dataTypeString = gDataInfo.dataTypes{dataNumber+1};
   implicitCastingEnabled = 1;
	initialValue = sf('get',data,'data.parsedInfo.initialValue');
	parentIsMachine = ~isempty(sf('get',dataParent,'machine.id'));
	parentIsFunction = ~isempty(sf('find',dataParent,'state.type','FUNC_STATE'));
	%% Function output data may be transformed due to inlining.
	%% Hence, we use the varName passed in from IR instead of cached fullnames
   dataName = varNameFromIR;    
	numDimensions = length(dataSizeArray);
   paramIndex = sf('get',data,'data.paramIndex');
   paramName = sprintf('p%d',paramIndex+1);
	isWorkspaceData = init_from_workspace(data);
	isMachineData = is_machine_data(data);
	if(~isWorkspaceData || ~gTargetInfo.codingRTW || isMachineData)
		error('why');
	end

SF_CODER_STR='';
	if(numDimensions==0)
SF_CODER_STR=[SF_CODER_STR,sprintf('	%s = (%s)%%<LibBlockParameter(%s,"", "", 0)>;\n',dataName,dataTypeString,paramName)];
	elseif(numDimensions==1)
		r = [dataName,'[%<i>]'];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%assign paramSizes = LibBlockParameterSize(%s)		\n',paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%if paramSizes[0]==1 && paramSizes[1]==1		\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i=%.15g\n',dataSizeArray(1))];
SF_CODER_STR=[SF_CODER_STR,sprintf('		   %s = (%s)%%<LibBlockParameter(%s,"", "", 0)>;\n',r,dataTypeString,paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%else\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i=%.15g\n',dataSizeArray(1))];
SF_CODER_STR=[SF_CODER_STR,sprintf('		   %s = (%s)%%<LibBlockParameter(%s,"", "", i)>;\n',r,dataTypeString,paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%endif\n')];
	elseif(numDimensions==2)
			r = [dataName,'[%<i1>][%<i2>]'];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%assign paramSizes = LibBlockParameterSize(%s)		\n',paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%if paramSizes[0]==1 && paramSizes[1]==1		\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i1=%.15g\n',dataSizeArray(1))];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i2=%.15g\n',dataSizeArray(2))];
SF_CODER_STR=[SF_CODER_STR,sprintf('		   %s = (%s)%%<LibBlockParameter(%s,"", "", 0)>;\n',r,dataTypeString,paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%else\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('      /* %%<paramSizes[0]> %%<paramSizes[1]> */\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('      %%assign singleCounter = 0\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i2=%.15g\n',dataSizeArray(2))];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%foreach i1=%.15g\n',dataSizeArray(1))];
SF_CODER_STR=[SF_CODER_STR,sprintf('		   %s = (%s)%%<LibBlockParameter(%s,"", "", singleCounter)>;\n',r,dataTypeString,paramName)];
SF_CODER_STR=[SF_CODER_STR,sprintf('         %%assign singleCounter = singleCounter+1\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('	   %%endforeach\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf('   %%endif	   \n')];
	else
			construct_coder_error(data,'Multidimensional arrays not allowed as workspace data.');
	end

	str = SF_CODER_STR;
	str(end) = [];

function initFromWorkspace = init_from_workspace(data)

	initFromWorkspace = sf('get',data,'data.initFromWorkspace');
	
function isMachineData = is_machine_data(data)

	if(~isempty(sf('get',sf('get',data,'data.linkNode.parent'),'machine.id')))
		isMachineData = 1;
	else
		isMachineData = 0;
	end
