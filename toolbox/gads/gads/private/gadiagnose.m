function gadiagnose(FUN,GenomeLength,options)
%GADIAGNOSE prints some diagnostic information about the problem
%   private to GA

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/09 16:15:45 $

properties =  optionsList('ga');
defaultOpt = gaoptimset;
Output_String = sprintf('\nDiagnostic information.');

Output_String = [Output_String sprintf('\n\tFitness function = %s',value2RHS(FUN))];
%print some information about constraints
if ~isempty(GenomeLength)
    Output_String = [Output_String sprintf('\n\tNumber of variables = %d',GenomeLength)];
end

Output_String = [Output_String sprintf('\n%s','Modified options:')];
for i = 1:length(properties)
    prop = properties{i};
    if(~isempty(prop)) % the property list has blank lines, ignore them
        value = options.(prop);
        if ~(isequal(value,defaultOpt.(prop)) || isempty(value)) 
            Output_String = [Output_String sprintf('\n\toptions.%s = %s',prop,value2RHS(value))];
        end
    end
end
Output_String = [Output_String sprintf('\nEnd of diagnostic information.')];
fprintf('%s',Output_String)
