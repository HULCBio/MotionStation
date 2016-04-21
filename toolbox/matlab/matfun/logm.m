function [L,exitflag] = logm(A)
%LOGM   Matrix logarithm.
%   L = LOGM(A) is the principal matrix logarithm of A, the inverse of EXPM(A).
%   L is the unique logarithm for which every eigenvalue has imaginary part
%   lying strictly between -PI and PI.  If A is singular or has any eigenvalues
%   on the negative real axis, then the principal logarithm is undefined,
%   a non-principal logarithm is computed, and a warning message is printed.
%
%   [L,EXITFLAG] = LOGM(A) returns a scalar EXITFLAG that describes
%   the exit condition of LOGM:
%   EXITFLAG = 0: successful completion of algorithm.
%   EXITFLAG = 1: one or more Taylor series evaluations did not converge.
%                 Computed F may still be accurate, however.
%   Note: this is different from R13 and earlier versions, which returned as
%   second output argument an expensive and often inaccurate error estimate.
%
%   Class support for input A:
%      float: double, single
%
%   See also EXPM, SQRTM, FUNM.

%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.11.4.2 $  $Date: 2004/04/10 23:30:00 $

if nargout < 2   
    L = funm(A,@log);  
else
    warnstate = warning;
    warning('off','MATLAB:funm:obsoleteEstErr');
    [L,exitflag] = funm(A,@log);
    warning(warnstate);
    warning('MATLAB:logm:obsoleteEstErr',...
           ['The second output changed from an error estimate',...
            ' to an exit flag.\n'...
            '         Please check the help for more information.'])   
end
