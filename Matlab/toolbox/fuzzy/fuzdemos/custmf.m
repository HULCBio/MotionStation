function y = custmf(x,params)
%CUSTMF Customized membership function for CUSTTIP.FIS.
%   This function is really just TRAPMF in disguise.
%   Copyright 1994-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $

y=trapmf(x,params);
