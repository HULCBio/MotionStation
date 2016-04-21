function model = setoptions(model,options)
%SETOPTIONS Set .fitoptions field of model.
%   NEWFITTYPE = SETOPTIONS(FITTYPE,OPTIONS) sets FITTYPE fitoptions field
%   to be OPTIONS.
%
%   See also FITTYPE.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:42:56 $

model.fitoptions = options;
