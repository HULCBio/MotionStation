function [err,x,fval,exitFlag,population,scores,r,c]= gaguirun(hproblem, hoptions, randchoice)
%GAGUIRUN GUI helper

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.23.4.1 $  $Date: 2004/04/06 01:09:52 $


% Set up dummy values in case of error
x = [1 1];
fval = [1 1];
exitFlag = '';
population = [ 1 1];
scores = [1 1];
r= [];
c = [];
err = '';
%Save new fields the appdata and read fields which are already there
[fitnessFcn,genomeLength,randstate,randnstate,errP] = gaguiReadProblem(hproblem);
%Save/read options fields before reacting to any errors
[options, errOpt] = gaguiReadHashTable(hoptions);
if ~isempty(errP)
    err = errP;
    return;
elseif ~isempty(errOpt)
    err = errOpt;
    return;
end

lasterr('');
lastwarn('');
warning off;
if randchoice
    rand('state', randstate);
    randn('state', randnstate);
end
try
[x,fval,e,output,population,scores] = ga(fitnessFcn, genomeLength, options);
gaResults.x = x; 
gaResults.fval = fval; 
gaResults.reason = e; 
gaResults.output = output; 
gaResults.population = population;
gaResults.scores = scores;
setappdata(0,'gads_gatool_results_121677',gaResults);
exitFlag = output.message;
catch 
    err = lasterr;
end

if isempty(err)
    % x and population might be logical - convert to double for GUI.
    if isa(x,'logical')
        x = double(x);
    end
    
    try
        
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
    end
    
    population = double(population);
    %Save the random states returned by GA in problem struct
    strct = getappdata(0,'gads_gatool_problem_data');
    strct.randstate = output.randstate;
    strct.randnstate = output.randnstate;
    setappdata(0,'gads_gatool_problem_data',strct);
end


