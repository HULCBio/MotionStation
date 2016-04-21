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

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $   $Date: 2002/03/27 00:15:37 $


%Load the look-up table GFPRIMPOLY
load gfprimpoly

[r,c]=size(inp);
ck=zeros(r,1);
inpu=zeros(r,1);
M=inp.m;
inp=double(inp.x);

if (M~=1)
        error('All elements must be in GF(2)');
    end
    
for i=1:r
    inpa=inp(i,:);
    inpu=bi2de(inpa,'left-msb');  
       
    %m is the order of the polynomial represented by a
    m=length(de2bi(inpu))-1;
    
    if m>16
        error('Order of polynomial represented by the input decimal elements must be lesser than or equal to 16');
    end
    
    if inpu<=1
        error('The decimal equivalent of the input polynomial(s) must be greater than 1');
    end
    
    %check for inpu in the look up table gfprimpoly{m}
    prims=gfprimpoly{m};
    indx=find(prims==inpu);
    
    if isempty(indx)
        ck(i,1)=0;
    else
        ck(i,1)=1;
    end
end


ck=logical(ck);


%--end of isprimitive--
