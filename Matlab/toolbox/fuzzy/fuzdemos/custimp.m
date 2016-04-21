function y=custimp(x1,x2)
%CUSTIMP Customized implication function for CUSTTIP.FIS.
%   OUT = CUSTIMP(IN1,IN2) calculates the implication output.
%   The implication operator must be able to support either one
%   or two inputs, such that CUSTIMP(X1,X2) == CUSTIMP([X1 X2]).
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $

if nargin==1,
    y=prod(x1).^2;
else
    y=(x1.*x2).^2;
end
