function mdlrefInfo = get_model_reference_info(modelName) 
   mdlrefInfo.isMultiInst = 0;
   mdlrefInfo.err = '';
   % Temprary solution (See geck 160992)
   if(feature('ModelReference')) 	
       mdlTarget = get_param(modelName,'ModelReferenceTargetType');
       if(strcmpi(mdlTarget, 'NONE') ~= 1 )
  	 %% Model reference SIM or RTW target	
         numInstAllowed = get_param(modelName, ...
				    'ModelReferenceNumInstancesAllowed');
         mdlrefInfo.isMultiInst = strcmp(numInstAllowed, 'Multi') == 1;
         mdlrefInfo.err = ['Cannot generate reusable model '            ...
	'reference target in the presence of machine parented data or ' ...
	'events. Consider updating the "Total number of instances '     ...
	'allowed per top model" parameter, in the Model Referencing '   ...
	'tab of Simulation parameters (Configuration) dialog, to "One".'];	
       end
   end	
