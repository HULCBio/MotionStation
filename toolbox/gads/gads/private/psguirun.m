function [err,x,fval,exitFlag,r,c]= psguirun(hproblem,hoptions,randchoice)
%PSGUIRUN GUI helper

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2004/04/06 01:09:54 $


% Set up dummy values in case of error
x = [1 1];
fval = [1 1];
exitFlag = '';
r = [];
c = [];
err = '';
%Save new fields the appdata and read fields which are already there
[fun,X0,aineq,bineq,aeq,beq,LB,UB,randstate,randnstate,errP] = psguiReadProblem(hproblem);
%Save/read options fields before reacting to any errors
[options, errOpt] = psguiReadHashTable(hoptions);
if ~isempty(errP)
    err = errP;
    return;
elseif ~isempty(errOpt)
    err = errOpt;
    return;
end

%Use the states if asked for and available
if randchoice
    rand('state', randstate);
    randn('state', randnstate);
end
%Save the current states anyway
strct = getappdata(0,'gads_psearchtool_problem_data');
strct.randstate = rand('state');
strct.randnstate = randn('state');
setappdata(0,'gads_psearchtool_problem_data',strct);

lasterr('');
lastwarn('');
warning off;
try
    [x,fval,e,output] = patternsearch(fun,X0,aineq,bineq,aeq,beq,LB,UB,options);
    psResults.x = x;
    psResults.fval = fval;
    psResults.exitMessage = e;
    psResults.output = output;
    setappdata(0,'gads_psearchtool_results_033051',psResults);
    exitFlag = output.message;
    if ndims(x) < 3 && (isnumeric(x) || isa(x,'double'))
        [r, c] = size(x);
    else
        r = -1;
        c = -1;
        x = [];
    end
 catch
     r = -1;
     c = -1;
     x = [];
     err = lasterr;
end

