function display(h);
%Display method for the operating report object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:12 $

if (length(h) == 1)
    disp(sprintf('\n Operating Point Search Report for the Model %s.',h.Model));
    disp(sprintf(' (Time-Varying Components Evaluated at time t=%d)\n',h.Time));
    
    disp(sprintf('%s\n',h.TerminationString))
    
    if isempty(h.States)
        disp(sprintf('States: None \n----------'))
    else
        disp(sprintf('States: \n----------'))
        %% Display the state objects    
        for ct = 1:length(h.States)
            h.States(ct).display(ct);
        end
    end
    
    disp(sprintf(' '));
    if isempty(h.Inputs)
        disp('Inputs: None')
    else
        disp(sprintf('Inputs: \n-----------'))
        %% Display the inputs
        h.Inputs
    end
    
    
    disp(sprintf(' '));
    if isempty(h.Outputs)
        disp('Outputs: None')
    else
        disp(sprintf('Outputs: \n-----------'))
        %% Displau the outputs
        h.Outputs
    end
    disp(sprintf(' '));
else
    disp(sprintf(['There is more than one operating report.  Select an element \n',... 
            'in the vector of operating reports to display.\n']))
end
