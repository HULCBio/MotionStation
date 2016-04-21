function fcn = makefcn(a,b,c)
%MAKEFCN Used by NESTEDDEMO.
% This function returns a handle to a customized version of 'parabola'.
% a,b,c specifies the coefficients of the function.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:56 $

fcn = @parabola;   % Return handle to nested function

    function y = parabola(x)
        % This nested function can see the variables 'a','b', and 'c'
        y = a*x.^2 + b.*x + c; 
    end
end
