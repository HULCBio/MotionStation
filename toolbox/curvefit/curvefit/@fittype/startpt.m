function num = startpt(model)
%STARTPT function to compute start point.
%   STARTPT(FITTYPE) returns the function handle of a function
%   to compute a starting point for FITTYPE based on xdata and ydata.
%   
%
%   See also FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:42:57 $

num = model.startpt;
