function y = csc(z)
%CSC    Cosecant.
%   CSC(X) is the cosecant of the elements of X.
%
%   See also ACSC, CSCD.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.8.4.2 $  $Date: 2003/11/18 03:10:39 $

if nargin==0 
  error('MATLAB:csc:NotEnoughInputs','Not enough input arguments.');
end

y = 1./sin(z);
