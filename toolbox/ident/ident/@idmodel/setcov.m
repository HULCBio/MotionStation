function  setcov(m)
%SETCOV  Performs auxiliary covariance calculations
%   SETCOV(M)
%
%   M is an estimated model of IDSS, IDGREY, or IDARX object type. 
%   Unless the property 'Covariance' has been set to 'None', M contains  
%   information about the uncertainty of the model. Several routines for
%   for evaluating and displaying this uncertainty  (BODE, SIM,
%   ZPPLOT, etc),
%   require some quite extensive calculations to transform this 
%   information.These are done whenever needed, and attempts are
%   made to store the results of the calulations. 
%
%   With SETCOV(M), these covariance calculations are carried out
%   and stored in M. It this takes time, a waitbar will appear
%   and give the possibility to cancel the calculations.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:22:13 $

[dum,mn,flag] = idpolget(m,[],'b');
if flag
    assignin('caller',inputname(1),mn);
end

