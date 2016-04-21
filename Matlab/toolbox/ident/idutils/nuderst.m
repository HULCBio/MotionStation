function nds = nuderst(pars)
%NUDERST        Selects the step size for numerical differentiation
%
%   NDS = nuderst(PARS)
%
%   PARS: The parameters, a row vector.
%   NDS: A row vector, whose k:th element is the step size to be used
%        for numerical differentiation with respect to the k:th parameter

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:21:54 $

nds = max(1e-7*ones(1,length(pars)),abs(pars(:)')*1e-4);
