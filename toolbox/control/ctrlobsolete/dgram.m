function g = dgram(a,b)
%DGRAM  Discrete controllability and observability gramians.
%   DGRAM(A,B) returns the discrete controllability gramian.
%   DGRAM(A',C') returns the observability gramian.
%   See also GRAM.

%   J.N. Little 9-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:34:23 $

%   Kailath, T. "Linear Systems", Prentice-Hall, 1980.
%   Laub, A., "Computation of Balancing Transformations", Proc. JACC
%     Vol.1, paper FA8-E, 1980.

g = gram(ss(a,b,[],[],-1),'c');
