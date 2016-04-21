function y = log(x)
% LOG  Logarithm in a Galois field.
%   Y = LOG(X) returns the answer y to the equation A.^y=x 
%   in a Galois field. Here, A is the primitive element, 
%   x is a Galois fields array, and y is an integer.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/02/05 15:16:16 $


if any(any(any(x==0)))
    error('Log of zero not defined for Galois Fields')
end

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
    [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
end

%If m equals 1, return zero
if GF_TABLE_M == 1
    y = zeros(size(x));
    return
end
if(isempty(GF_TABLE1))
    % no tables in memory, or MAT file, need to create them
    m = x.m;
    prim_poly = x.prim_poly;
    x2=gf(0:2^m-1,m, prim_poly)';
    x1 = gf(zeros(1,2^m),m,prim_poly);
    %create the tables locally, but allow warning to be issued.
    S.type ='()';
    S.subs = {3};
    temp =subsref(x2,S);
    x1 = temp.^(0:2^m-1);
    ind=x1.x;
    ind=double(ind);
    ind(end)=[];
    x2=0*ind; 
    i=0:2^m-2;
    x2(ind)=i;
    GF_TABLE2 = [x2'];
end

objsize=size(x);
if objsize(1) == 1 & length(objsize) == 2
%If x is a row vector, use transpose    
    y=double(GF_TABLE2(x.x)');
else
    y=double(GF_TABLE2(x.x));
end