% [A,B,flag]=lmicoef(t,data)
%
% Retrieves the coefficient(s) stored in term record "t".
%  * if the term is an outer factor or a constant coefficient,
%    it is returned in A (B=[])
%  * if the term is variable, returns the coeffs. A and B.
%    Scalar coefficients are returned as such.
%
% FLAG is 1 for self-conjugated terms
%
% LOW-LEVEL FUNCTION

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [A,B,flag]=lmicoef(t,data)

B=[]; flag=0;
shft=t(5);        % base of data segment in DATA

% get A
rA=data(shft+1); cA=data(shft+2);
shft=shft+2; aux=rA*cA;
A=ve2ma(data(shft+1:shft+aux),2,[rA,cA]);



% get B if necessary
if ~(t(2) & t(4)), return, end

shft=shft+aux;
rB=data(shft+1); cB=data(shft+2);
shft=shft+2; aux=rB*cB;
B=ve2ma(data(shft+1:shft+aux),2,[rB,cB]);
flag=data(shft+aux+1);

