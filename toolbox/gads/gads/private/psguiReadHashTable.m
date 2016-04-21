function [options, err] = psguiReadHashTable(h)
% Transfers data from the java gui to a psoptimset struct.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.12 $

% you will never call this yourself, only the GUI handling code will use
% it.

options = getappdata(0,'gads_psearchtool_options_data');
err = '';
try
    options = getProperty(h,options,'TolMesh');
    options = getProperty(h,options,'TolX');
    options = getProperty(h,options,'TolFun');
    options = getProperty(h,options,'TolBind');
    options = getMaxIterProperty(h, options);
    options = getMaxFunEvalProperty(h, options);
    options = getProperty(h,options,'MeshContraction');
    options = getProperty(h,options,'MeshExpansion');
    options = getProperty(h,options,'MeshAccelerator', true);
    options = getProperty(h,options,'MeshRotate', true);
    options = getProperty(h,options,'InitialMeshSize');
    options = getProperty(h,options,'ScaleMesh', true);
    options = getProperty(h,options,'MaxMeshSize');
    options = getProperty(h,options,'PollMethod', true);
    options = getProperty(h,options,'CompletePoll', true);
    options = getProperty(h,options,'PollingOrder', true);
    options = getProperty(h,options,'SearchMethod');
    options = getProperty(h,options,'CompleteSearch', true);
    options = getProperty(h,options,'Display', true);
    options = getProperty(h,options,'OutputFcns');
    options = getProperty(h,options,'PlotFcns');
    options = getProperty(h,options,'PlotInterval');
    options = getProperty(h,options,'Cache', true);
    options = getProperty(h,options,'CacheSize');
    options = getProperty(h,options,'CacheTol');
    options = getProperty(h,options,'Vectorized', true);

catch
    err = lasterr;
end
setappdata(0,'gads_psearchtool_options_data',options);

% getProperty-------------------------------------------
function options = getProperty(h,options,name,stringify)
if h.containsKey(name)
    v = h.get(name);
else
    return;
end

if(nargin < 4)
    stringify = false;
end
   
if(~stringify)
    try
        v = evalin('base', v);
    catch
        opt = getappdata(0,'gads_psearchtool_options_data');
        if ~isempty([strfind(v,'<userStructure>')  strfind(v,'<userClass>') strfind(v,'<userData>')])
            v = opt.(name);
        end
        
    end
end

options.(name) = v;

% getMaxIterProperty-------------------------------------------
% MaxIter can take both strings and doubles. (this may change)
% todo resolve this issue
function options = getMaxIterProperty(h,options)
v = h.get('MaxIteration');
if strcmp(v, '100*numberofvariables') 
    options.MaxIteration = v;
else
    options = getProperty(h, options, 'MaxIteration');
end

% getMaxFunEvalProperty-------------------------------------------
% MaxFunEval can take both strings and doubles. (this may change)
% todo resolve this issue
function options = getMaxFunEvalProperty(h,options)
v = h.get('MaxFunEvals');
if strcmp(v, '2000*numberofvariables') 
    options.MaxFunEvals = v;
else
    options = getProperty(h, options, 'MaxFunEvals');
end




