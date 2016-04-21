function [v,idx] = addvar(this, varid, varInfo)
%ADDVAR Error method to prevent HDS adding additional variables
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:35:47 $
error('timeseries:addvar:notimp',...
    'The addvar method cannot be applied to time series objects')
