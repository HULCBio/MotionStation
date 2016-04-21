function [ber, numBits] = bertooltemplate(EbNo, maxNumErrs, maxNumBits)
%BERTOOLTEMPLATE Template for a BERTool simulation function.
%   This M-file is a template for a BERTool-compatible
%   simulation function.  To use the template, insert your
%   own code in the places marked "INSERT YOUR CODE HERE"
%   and save the result as a file on your MATLAB path.
%   Then use the Monte Carlo panel of BERTool to execute
%   the script.
%
%   For more information about this template and an example
%   that uses it, see the Communications Toolbox documentation.
%
%   See also BERTOOL, VITERBISIM.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/03/24 20:32:33 $

% Import Java class for BERTool.
import com.mathworks.toolbox.comm.BERTool;

% Initialize variables related to exit criteria.
totErr  = 0; % Number of errors observed
numBits = 0; % Number of bits processed

% --- Set up parameters. ---
% --- INSERT YOUR CODE HERE.

% Simulate until number of errors exceeds maxNumErrs
% or number of bits processed exceeds maxNumBits.
while((totErr < maxNumErrs) && (numBits < maxNumBits))

   % Check if the user clicked the Stop button of BERTool.
   if (BERTool.getSimulationStop)
      break;
   end

   % --- Proceed with simulation.
   % --- Be sure to update totErr and numBits.
   % --- INSERT YOUR CODE HERE.

end % End of loop

% Compute the BER.
ber = totErr/numBits;
