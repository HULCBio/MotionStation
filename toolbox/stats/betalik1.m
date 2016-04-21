function logL = betalik1(params,ld,l1d,n)
%BETALIK1 is a helper function. It is the same as BETALIKE, except it
% directly computes the betapdf without calling BETAPDF, also, saved some
% error checking and size checking.

%   ZP You 3-8-99
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.1 $  $Date: 2004/01/24 09:33:03 $

a = params(1);
b = params(2);

logL = n*betaln(a,b)+(1-a)*ld+(1-b)*l1d;


