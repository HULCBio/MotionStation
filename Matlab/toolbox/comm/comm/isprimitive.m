function ck = isprimitive(inp)
%ISPRIMITIVE Check whether a polynomial over a Galois field is primitive.
%   CK = ISPRIMITIVE(A) checks whether A is a primitive polynomial. A can be 
%   either degree-M GF(2) polynomial or its decimal equivalent A. The order
%   of A must be lesser than or equal to 16. 
%   The output CK is as follows:
%       CK =  0   A is not a primitive polynomial;
%       CK =  1   A is a primitive polynomial.
%   
%   If A is a GF(2) matrix, then each row must correspond to a polynomial. CK is 
%   a column vector with each element corresponding to a row of A.
%   If A is a column vector of decimals, CK is a column vector with each element 
%   corresponding to an element of A.
%
%   See also PRIMPOLY.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $   $Date: 2004/04/12 23:00:46 $

[r,c]=size(inp);

if (r>1) & (c>1)
    error('Input cannot be a matrix');
end

%Make the input row vector if its entered as a coulmn vector
if c>1
    error('A must be a column vector');
end

if any(inp<=1) | any(inp-floor(inp))
    error('A must be nonnegative integer(s) greater than one');
end

%Load the look-up table GFPRIMPOLY
load gfprimpoly
ck=zeros(length(inp),1);
for i=1:length(inp)
    a=inp(i,1);
    %m is the order of the polynomial represented by a
    ab=de2bi(a);
    m=length(ab)-1;
    
    if m>16
        error('Order of polynomial represented by the input decimal elements must be lesser than or equal to 16');
    end
    
    
    %check for a in the look up table gfprimpoly
    prims=gfprimpoly{m};
    indx=find(prims==a);
    if isempty(indx)
        ck(i,1)=0;
    else
        ck(i,1)=1;
    end
end
   
ck=logical(ck);


%--end of isprimitive--
