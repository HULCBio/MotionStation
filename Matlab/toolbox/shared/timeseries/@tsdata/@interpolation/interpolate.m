function out = interpolate(h,time,data,t, varargin)
%INTERPOLATE Perform interpolation using the interpolation object 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:17 $

% Force time to be aligned with the specified dimension before passing
% to the interpolation function which always assumes that time is 
% aligned with the 1st dimension
if nargin>=5
    n = ndims(data);
    data = permute(data,[varargin{1} 1:(varargin{1}-1) (varargin{1}+1):n]);
end    
    
% h.fhandle is either a function_handle or a cell arrray where
% the first element is a function_handle
if iscell(h.fhandle)
    out = tsarrayFcn({h.fhandle{:} t}, time, data, length(t));
elseif isa(h.fhandle,'function_handle')
    % Interpolation always acts independently on 'columns' and so can
    % be defered to the tsarrayFcn for handling NaNs
    out = tsarrayFcn({h.fhandle t}, time, data, length(t));
else
    error('interpolation:interpolate:invalfhandle','Invalid function handle')
end

% If the data matrix was permuted to get time to be aligned with the
% first dim, permute back
if nargin>=5
    out = permute(out,[2:varargin{1} 1 (varargin{1}+1):n]);
end