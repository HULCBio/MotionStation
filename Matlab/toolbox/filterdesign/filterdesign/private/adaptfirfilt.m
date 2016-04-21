function [y,e,S] = adaptfirfilt(x,d,S,updatefcn)
% ADAPTFIRFILT   Adaptive FIR filter.

%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:38:54 $

for n = 1:length(x)
    % Call preadapt to filter the input and update the filter state
    [y(n),e(n),Zf] = preadaptfir(x(n),d(n),S);
    
    % Call update function to perform algorithm specific updates
    S = feval(updatefcn,x(n),e(n),S);
	  
    % Update FIR filter states, increment counter.
    S.states = Zf;
    S.iter = S.iter + 1;
end

% [EOF]
