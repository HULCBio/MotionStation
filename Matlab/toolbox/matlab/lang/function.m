%FUNCTION Add new function.
%   New functions may be added to MATLAB's vocabulary if they
%   are expressed in terms of other existing functions. The 
%   commands and functions that comprise the new function must
%   be put in a file whose name defines the name of the new 
%   function, with a filename extension of '.m'. At the top of
%   the file must be a line that contains the syntax definition
%   for the new function. For example, the existence of a file 
%   on disk called STAT.M with:
% 
%           function [mean,stdev] = stat(x)
%           %STAT Interesting statistics.
%           n = length(x);
%           mean = sum(x) / n;
%           stdev = sqrt(sum((x - mean).^2)/n);
% 
%   defines a new function called STAT that calculates the 
%   mean and standard deviation of a vector. The variables
%   within the body of the function are all local variables.
%   See SCRIPT for procedures that work globally on the work-
%   space. 
%
%   A subfunction that is visible to the other functions in the
%   same file is created by defining a new function with the FUNCTION
%   keyword after the body of the preceding function or subfunction.
%   For example, avg is a subfunction within the file STAT.M:
%
%          function [mean,stdev] = stat(x)
%          %STAT Interesting statistics.
%          n = length(x);
%          mean = avg(x,n);
%          stdev = sqrt(sum((x-avg(x,n)).^2)/n);
%
%          %-------------------------
%          function mean = avg(x,n)
%          %AVG subfunction
%          mean = sum(x)/n;
%
%   Subfunctions are not visible outside the file where they are defined.
%   Normally functions return when the end of the function is reached.
%   A RETURN statement can be used to force an early return.
%
%   See also SCRIPT, RETURN, VARARGIN, VARARGOUT, NARGIN, NARGOUT, 
%            INPUTNAME, MFILENAME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.13.4.1 $  $Date: 2002/09/17 19:03:15 $
%   Built-in function.
