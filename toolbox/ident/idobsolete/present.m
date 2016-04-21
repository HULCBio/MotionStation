function present(th)
%PRESENT  presents a parametric model on the screen.
%   PRESENT(TH)
%
%   This function displays the model TH together estimated standard
%   deviations, innovations variance, loss function and Akaike's Final
%   Prediction Error criterion (FPE).

%   L. Ljung 10-1-86
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:21:40 $

if nargin < 1
   disp('Usage: PRESENT(TH)')
   return
end
th
 