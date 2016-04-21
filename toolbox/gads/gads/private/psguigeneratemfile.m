function psguigeneratemfile(probmodel, optmodel, randchoice)
%PSGUIGENERATEMFILE generates an mfile from psearchtool. 

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.6 $

%problem fields
[fun,X0,Aineq,Bineq,Aeq,Beq,LB,UB,randstate,randnstate] =  psguiReadProblem(probmodel);

%Options fields
options = psguiReadHashTable(optmodel);

%remove special gui outputfcn which is the first in the list
if ~isempty(options.OutputFcns) 
    temp = options.OutputFcns{1};
    temp = temp{1};
    if strcmp(func2str(temp), 'psearchtooloutput')
        options.OutputFcns(1) = [];
    end
end
%Create a struct for generateMfile
tempstruct = struct;
tempstruct.objective=fun;
tempstruct.X0=X0;
tempstruct.LB = LB;
tempstruct.UB = UB;
tempstruct.Aineq = Aineq;
tempstruct.Bineq = Bineq;
tempstruct.Aeq = Aeq;
tempstruct.Beq = Beq;
if randchoice
    tempstruct.randstate = randstate;
    tempstruct.randnstate = randnstate;
end
tempstruct.options=options;

%call generate M-file code
generateMfile(tempstruct, 'ps');
