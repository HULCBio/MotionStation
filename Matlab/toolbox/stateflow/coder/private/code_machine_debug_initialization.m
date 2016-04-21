function code_machine_debug_initialization(file)

		global gMachineInfo gDataInfo gTargetInfo
      
      v1=gMachineInfo.machineName;
      v2 = gMachineInfo.targetName;
      v3 = gTargetInfo.codingLibrary;
      v4 = length(gMachineInfo.charts);
      v5 = length(gMachineInfo.machineData);
      v6 = length(gMachineInfo.machineEvents);
      v7 = length(gMachineInfo.machineDataWithChangeEvent);
fprintf(file,'	%s = sf_debug_initialize_machine("%s","%s",%.15g,%.15g,%.15g,%.15g,%.15g);\n',gMachineInfo.machineNumberVariableName,v1,v2,v3,v4,v5,v6,v7);
		index = 0;
		for data = gMachineInfo.machineDataWithChangeEvent
		   v1 = gMachineInfo.machineNumberVariableName;
		   v2 = index;
		   v3 = sf('get',data,'data.number');
fprintf(file,'	sf_debug_set_number_of_data_with_change_event_for_machine(%s,%.15g,%.15g);\n',v1,v2,v3);
			index = index+1;
		end
		v1 = gMachineInfo.machineNumberVariableName;
		v2 = gMachineInfo.machineEventThreshold;
		v3 = gMachineInfo.machineDataChangeEventThreshold;
fprintf(file,'	sf_debug_set_machine_event_thresholds(%s,%.15g,%.15g);\n',v1,v2,v3);
      v1 = gMachineInfo.machineNumberVariableName;
      v2 = gMachineInfo.machineDataThreshold;
fprintf(file,'	sf_debug_set_machine_data_thresholds(%s,%.15g);\n',v1,v2);
		for dataNumber = [gMachineInfo.localDataNumbers,gMachineInfo.exportedDataNumbers,gMachineInfo.importedDataNumbers,gMachineInfo.constantDataNumbers,gMachineInfo.parameterDataNumbers]
			data = gDataInfo.dataList(dataNumber+1);
			dataSizeArray = gDataInfo.dataSizeArrays{dataNumber+1};
			v1 = gMachineInfo.machineNumberVariableName;
			v2 = dataNumber;
			v3 = sf('get',data,'data.scope');
fprintf(file,'	sf_debug_set_machine_data_scope(%s,%.15g,%.15g);\n',v1,v2,v3);
         v1 = gMachineInfo.machineNumberVariableName;
			v2 = dataNumber;
			v3 = sf('get',data,'data.name');
fprintf(file,'   sf_debug_set_machine_data_name(%s,%.15g,"%s");\n',v1,v2,v3);
			coderDataType = sf('CoderDataType',data);
			if(strcmp(coderDataType,'fixpt'))
				[fixPtBaseType,fixptExponent,fixptSlope,fixptBias,nBits,isSigned] =...
					sf('FixPtProps',data);
				isFixedPoint = '1';
				biasStr = sprintf('%.17g',fixptBias);
				slopeStr = sprintf('%.17g',fixptSlope);
				exponentStr = sprintf('%d',fixptExponent);
			else
				isFixedPoint = '0';
				biasStr = '0.0';
				slopeStr = '1.0';
				exponentStr = '0';
			end				
			v1 = gMachineInfo.machineNumberVariableName;
			v2 = dataNumber;
			v3 = gDataInfo.sfDataTypes{dataNumber+1};
			v4 = sf('get',data,'data.isComplex');
			v5 = isFixedPoint;
			v6 = biasStr;
			v7 = slopeStr;
			v8 = exponentStr;
fprintf(file,'	sf_debug_set_machine_data_type(%s,%.15g,%s,%.15g,%s,%s,%s,%s);\n',v1,v2,v3,v4,v5,v6,v7,v8);
			if(length(dataSizeArray)==0)
fprintf(file,'	sf_debug_set_machine_data_size(%s,%.15g,0,NULL);\n',gMachineInfo.machineNumberVariableName,dataNumber);
fprintf(file,'	sf_debug_set_machine_data_value_ptr(%s,%.15g,NULL);\n',gMachineInfo.machineNumberVariableName,dataNumber);
			else
fprintf(file,'	{\n');
fprintf(file,'		unsigned int dimVector[%.15g];\n',length(dataSizeArray));
				zeroIndexString = '';
				for i=0:length(dataSizeArray)-1
					zeroIndexString = ['[0]',zeroIndexString];
fprintf(file,'		dimVector[%.15g]= %.15g;\n',i,dataSizeArray(i+1));
				end
fprintf(file,'		sf_debug_set_machine_data_size(%s,%.15g,%.15g,&(dimVector[0]));\n',gMachineInfo.machineNumberVariableName,dataNumber,length(dataSizeArray));
fprintf(file,'		sf_debug_set_machine_data_value_ptr(%s,%.15g,NULL);\n',gMachineInfo.machineNumberVariableName,dataNumber);
fprintf(file,'	}\n');
			end
		end
		for event = [gMachineInfo.localEvents,gMachineInfo.exportedEvents]
			[eventNumber,eventScope] = sf('get',event,'event.number','event.scope');
fprintf(file,'	sf_debug_set_machine_event_scope(%s,%.15g,%.15g);\n',gMachineInfo.machineNumberVariableName,eventNumber,eventScope);
		end
