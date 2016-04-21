function y = taxDemo(income)
%TAXDEMO Used by NESTEDDEMO.
% Calculate the tax on income.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:47:05 $

AdjustedIncome = income - 6000; % Calculate adjusted income

% Call 'computeTax' without passing 'AdjustedIncome' as a parameter.

y = computeTax; 

    function y = computeTax
        
        % This function can see the variable 'AdjustedIncome'
        % in the calling function's workspace
        y = 0.28 * AdjustedIncome;
    end
end
