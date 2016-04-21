function z = cosint(x)
%COSINT Cosine integral function.
%  COSINT(x) = Gamma + log(x) + int((cos(t)-1)/t,t,0,x)
%  where Gamma is Euler's constant, .57721566490153286060651209...
%  Euler's constant can be evaluated with vpa('eulergamma').
%
%  See also SININT.

%   Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.12 $  $Date: 2002/04/15 03:13:41 $ 

z = double(cosint(sym(x)));
