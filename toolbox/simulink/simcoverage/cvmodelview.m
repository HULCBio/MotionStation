function cvmodelview(covdata,metricNames)
%CVMODELVIEW - Display coverage data by coloring a model.
%
%   CVMODELVIEW(DATA) Display coverage data on a the model
%   by coloing the Simulink and Stateflow diagrams to indicate
%   what contructs have not been completely tested. Additionaly 
%   a textual information window 
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:34:36 $

    if slfeature('CoverageDiagramUI')==0
        return;
    end

    if nargin<2
    allMetrics = fieldnames(covdata.metrics);
    metricNames = {};
    for i=1:length(allMetrics)
        if ~isempty(getfield(covdata.metrics,allMetrics{i}))
            metricNames{end+1} = allMetrics{i};
        end
    end
    end
    
    if ( ~( any(strcmp(metricNames,'decision')) || ...
            any(strcmp(metricNames,'condition')) || ...
            any(strcmp(metricNames,'sigrange'))))
        disp('There is no structural coverage or signal range coverage to display');
        return;        
    end        
            
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Look for the variable 
    % 'BnT_simcoverage_testing' to
    % disable actual display
    try,
        prevLastErr = lasterr;
        MathWorksTesting = evalin('base','BnT_simcoverage_testing');
    catch
        lasterr(prevLastErr);
        MathWorksTesting = 0;
    end

    [cvstruct,sysCvIds] = report_create_structured_data({covdata}, covdata.id, metricNames);

    if MathWorksTesting
        informerUddObj = [];
    else
        informerUddObj = get_informer;
        informerUddObj.title = ['Coverage: ' cvstruct.model.name];
        informerUddObj.defaultText = default_informer_text;
        informerUddObj.show;
        cv('set',cvstruct.model.cvId ,'modelcov.currentDisplay.informer',  informerUddObj);
    end
    
    cv_display_on_model(cvstruct, metricNames, informerUddObj);

    informer_add_close_callback(informerUddObj, cvstruct.model.cvId);
    
  
