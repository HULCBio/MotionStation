function [fun,nvars,randstate,randnstate, err] =  gaguiReadProblem(h)
%private to psguirun, exportps2ws psguigeneratemfile

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2004/01/16 16:51:14 $

problem = getappdata(0,'gads_gatool_problem_data');
err = '';
[problem, errs] = getData(h,problem,'fitnessfcn');
err = [err errs];        
[problem, errs] = getData(h,problem,'nvars');
err = [err errs];        
[problem, errs] = getData(h,problem,'randstate');
err = [err errs];        
[problem, errs] = getData(h,problem,'randnstate');
err = [err errs];        
setappdata(0,'gads_gatool_problem_data',problem);
%Retrieve all the members
fun = problem.fitnessfcn; nvars = problem.nvars; 
randstate = problem.randstate; randnstate = problem.randnstate;

%-------------------getData------------------------
function [problem, err] = getData(h,problem,name)
err = '';
if h.containsKey(name)
    v = h.get(name);
else
    return;
end

try
    v = evalin('base', v);
catch
    strct = getappdata(0,'gads_gatool_problem_data');
    if ~isempty([strfind(v,'<userStructure>')  strfind(v,'<userClass>') strfind(v,'<userData>')])
        v = strct.(name);
    end
    err = sprintf('Error in %s: %s \n', name, lasterr);
end
problem.(name) = v;
