function result = eml_chart_man(methodName, objectId, varargin)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/15 00:57:20 $

result = [];

% Input object much be eML chart
if ~sf('ishandle',objectId) || ~is_eml_chart(objectId)
    return;
end

try,
    switch(methodName)
        case {'update_active_instance', 'create_ui', 'get_eml_prototype'}
            result = feval(methodName, objectId);
        case {'sync_prototype', 'translate_eml_chart_script'}
            result = feval(methodName, objectId, varargin{:});
        otherwise
            disp(sprintf('Unknown methodName %s passed to eml_chart_man', methodName));
    end
catch,
    str = sprintf('Error calling eml_chart_man(%s): %s',methodName,lasterr);
    construct_error(objectId, 'Embedded MATLAB', str, 0);
    slsfnagctlr('ViewNaglog');
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following functions are for eML chart block            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sync_prototype(chartId, varargin)

result = [];
eMLId = eml_fcns_in(chartId);
if isempty(eMLId)
    return;
end
objectId = eMLId(1);
newPrototypeStr = '';
stylingBySeq = 0;

if (nargin > 1)
    % The sync direction is from chart IO to eML script
    % Make sure Statflow get updated eML script from eML editor.
    eml_function_man('update_data', objectId);

    newPrototypeStr = varargin{1};
    
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str', script);
else
    % The sync direction is from eML script to chart IO
    stylingBySeq = 1;
    
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str', script);
    if (st ~= 0)
        % Reconcile only when valid prototype is present in script
        [funcName,inData,outData,obsData] = reconcile_function_io(chartId);
        sf('set', chartId, 'chart.eml.name', funcName); % Cache the function name as eML chart name
    end
    newPrototypeStr = sf('ChartPrototype', chartId);
end

if (st == 0)
    % Fix function prototype in script
    eml_function_man('update_script_prototype', objectId, script, ['function ' newPrototypeStr 10], st,en);
elseif ~function_prototype_utils('compare', newPrototypeStr, pStr)
    % Update function prototype in script
    newPrototypeStr = function_prototype_utils('style', newPrototypeStr, pStr, stylingBySeq);
    eml_function_man('update_script_prototype', objectId, script, ['function ' newPrototypeStr], st,en);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = get_function_from_chart(chartId)
fcnIds = eml_fcns_in(chartId);
f = [];
if ~isempty(fcnIds)
  f = fcnIds(1);
end
  
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('create_ui', result);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('update_active_instance', result);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_eml_prototype(chartId)

result = [];
emlFunc = eml_fcns_in(chartId);
if(~isempty(emlFunc))
    result = eml_function_man('get_eml_prototype', emlFunc(1));
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = translate_eml_chart_script(chartId, fcnName)

result = ['function ' fcnName 10];

emlFunc = eml_fcns_in(chartId,'all');
if(~isempty(emlFunc))
    script = sf('get', emlFunc(1), 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str', script);
    if (st == 0)
        % no prototype found, fix it. Should only happen if prototype sync failed
        result = [result script];
        warning('Embedded MATLAB function prototype not in sync.');
    else
        result = [script(1:st-1) result script(en+1:end)];
    end
end

return;
