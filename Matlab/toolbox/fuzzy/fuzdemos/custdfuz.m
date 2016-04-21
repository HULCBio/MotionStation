function y=custdfuz(x,mf)
%CUSTDFUZ Customized defuzzification function for CUSTTIP.FIS
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $

y=defuzz(x,mf,'centroid')/2;
