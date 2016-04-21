% EQ_COSTFCNBLK is the open function block of the Cost Function block
% in the equalizers demo.
%
% This function assumes that the following variables are defined in the workspace:
% chCoeff, numTaps and snrdB.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/05/17 16:43:43 $

if numTaps <= 2 & Mconst == 2,
    
    sigma2S = 1;
    str1 = 'Initial Settings';
    
    %-- Get selected algorithm from Initial Settings block mask
    if(~isempty(find_system(bdroot,'Regexp','on','Name',str1)))
        alg = get_param([bdroot '/' str1],'eqAlg');
    else % default case
        alg = 'LMS - Least-Mean-Square';
    end
    
    %-- Plot cost function, get IC
    ic = eq_computecostfcn(chCoeff, numTaps, 1, 10^(-snrdB/10), 50, 0.5, alg);
    
    %-- Set initial conditions in Initial Settings block mask
    if(~isempty(find_system(bdroot,'Regexp','on','Name',str1)))
        set_param([bdroot '/' str1],'ic',['[' num2str(ic') ']']);
    else
        assignin('base','ic',ic);
    end
    
else
        
    m=msgbox(['To plot the MSE cost function, open the main mask and set'...
            ' the number of coefficient taps and the number of' ... 
            ' constellation points equal to 2.'],'Plot cost function','help');
end

% end of eq_costfcnblk.m