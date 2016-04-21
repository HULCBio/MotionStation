function [fun,X0,Aineq,Bineq,Aeq,Beq,LB,UB,randstate,randnstate, err] =  psguiReadProblem(h)
%private to psguirun, exportps2ws psguigeneratemfile

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2004/01/16 16:51:15 $

problem = getappdata(0,'gads_psearchtool_problem_data');
err = '';
[problem, errs] = getData(h,problem,'objective');
err = [err errs];
[problem, errs] = getData(h,problem,'X0');
err = [err errs];
[problem, errs] = getData(h,problem,'Aineq');
err = [err errs];
[problem, errs] = getData(h,problem,'Bineq');
err = [err errs];
[problem, errs] = getData(h,problem,'Aeq');
err = [err errs];
[problem, errs] = getData(h,problem,'Beq');
err = [err errs];
[problem, errs] = getData(h,problem,'LB');
err = [err errs];
[problem, errs] = getData(h,problem,'UB');
err = [err errs];
[problem, errs] = getData(h,problem,'randstate');
err = [err errs];
[problem, errs] = getData(h,problem,'randnstate');
err = [err errs];
    
setappdata(0,'gads_psearchtool_problem_data',problem);
%Retrieve all the members
fun = problem.objective; X0 = problem.X0; Aineq = problem.Aineq; Bineq = problem.Bineq;
Aeq = problem.Aeq; Beq = problem.Beq; LB = problem.LB; UB = problem.UB;
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
    strct = getappdata(0,'gads_psearchtool_problem_data');
    if ~isempty([strfind(v,'<userStructure>')  strfind(v,'<userClass>') strfind(v,'<userData>')])
        v = strct.(name);
    end
    err = sprintf('Error in %s: %s \n', name, lasterr);
end
problem.(name) = v;
