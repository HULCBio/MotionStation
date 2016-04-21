function gaguigeneratemfile(probmodel, optmodel, randchoice)
%GAGUIGENERATEMFILE generates an mfile from gatool. 

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2004/01/16 16:50:57 $

[fitnessFcn,nvars,randstate,randnstate] =  gaguiReadProblem(probmodel);

options = gaguiReadHashTable(optmodel);

%remove special gui outputfcn which is the first in the list
if ~isempty(options.OutputFcns) 
    temp = options.OutputFcns{1};
    temp = temp{1};
    if strcmp(func2str(temp), 'gatooloutput')
        options.OutputFcns(1) = [];
    end
end
%Create a struct for generateMfile
tempstruct = struct;
tempstruct.fitnessfcn = fitnessFcn;
tempstruct.nvars = nvars;
if randchoice
    tempstruct.randstate = randstate;
    tempstruct.randnstate = randnstate;
end
tempstruct.options=options;
%Call generate Mfile code
generateMfile(tempstruct, 'ga');
