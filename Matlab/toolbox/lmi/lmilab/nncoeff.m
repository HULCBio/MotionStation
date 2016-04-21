%    LOW-LEVEL FUNCTION   [A,B,flag]=nncoeff(t,data,task)
%
%    Retrieves the coefficient(s) associated with a LMI term T
%
%    TASK=0 (variable term AXB) ->
%              returns A and B' in MA2VE form
%    TASK=1 (scalar var. term x*(A*B) ) ->
%              returns A*B in MA2VE form
%    TASK=2 (outer factor N) ->
%              returns N' in MA2VE form (as stored in T)
%
%    FLAG is 1 for self-conjugated terms in diagonal blocks
%

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [A,B,flag]=nncoeff(t,data,task)

B=[]; flag=0;
shft=t(5);        % base of data segment in DATA


rA=data(shft+1); cA=data(shft+2);
shft=shft+2; aux=rA*cA;

if task==2,   % outer fact
   A=ma2ve(reshape(data(shft+1:shft+aux),cA,rA),2);    % N^T
   return
end

A=ve2ma(data(shft+1:shft+aux),2,[rA,cA]);
shft=shft+aux;

rB=data(shft+1); cB=data(shft+2);
shft=shft+2; aux=rB*cB; flag=data(shft+1+aux);


if task,   % scalar variable
   B=ve2ma(data(shft+1:shft+aux),2,[rB,cB]);
   A=ma2ve(A*B,2);
else
   A=ma2ve(A,2);
   B=ma2ve(reshape(data(shft+1:shft+aux),cB,rB),2);   % B^T
end

%A,B
