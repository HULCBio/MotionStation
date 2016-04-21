function y = mean2(x)
%MEAN2 Compute mean of matrix elements.
%   B = MEAN2(A) computes the mean of the values in A.
%
%   Class Support
%   -------------
%   A can be numeric or logical. B is a scalar of class double. 
%
%   Example
%   -------
%       I = imread('liftingbody.png');
%       val = mean2(I)
%  
%   See also MEAN, STD, STD2.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.19.4.4 $  $Date: 2003/08/23 05:53:01 $

y = sum(x(:), [], 'double') / numel(x);
