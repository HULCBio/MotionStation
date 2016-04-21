function y = subplus(x)
%SUBPLUS Positive part.
%
%                                  x , if  x>=0
%   y  = subplus(x) := (x)_{+}  =               ,
%                                  0 , if  x<=0
%
%  returns the positive part of X. Used for computing truncated powers.

%   Carl de Boor 26 nov 88; 6sep97 (switch to use of MAX)
%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
%   $Revision: 1.14 $

y=max(x,zeros(size(x)));