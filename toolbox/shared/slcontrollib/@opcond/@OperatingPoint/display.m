function display(h);
%Display method for the operating condition object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:06 $

if (length(h) == 1)
    disp(sprintf('\n Operating Point for the Model %s.',h.Model));
    disp(sprintf(' (Time-Varying Components Evaluated at time t=%d)\n',h.Time));
        
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
        h.Inputs.display
    end
else
    disp(sprintf(['There is more than one operating point.  Select an element \n',... 
            'in the vector of operating points to display.\n']))
end
