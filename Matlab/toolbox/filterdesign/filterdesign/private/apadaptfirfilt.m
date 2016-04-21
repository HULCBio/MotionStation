function [y,e,S] = apadaptfirfilt(x,d,S,updatefcn)
%APADAPTFIRFILT   A priori adaptive FIR filter.
%   Adaptive FIR filter with a priori coefficient update.
%   This function, used by ADPATRLS, uses an apriori error
%   to compute the coefficient update. Th a posteriori error
%   is computed with the updated coefficients and returned as
%   an output.


%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:39:24 $

for n = 1:length(x)
    
    % Call update function to perform algorithm specific updates
    S = feval(updatefcn,x(n),d(n),S);
	  
	% Call preadapt to filter the input and update the filter state
    [y(n),e(n),Zf] = preadaptfir(x(n),d(n),S);
    
    % Update FIR filter states, increment counter.
    S.states = Zf;
    S.iter = S.iter + 1;
end

% [EOF]
