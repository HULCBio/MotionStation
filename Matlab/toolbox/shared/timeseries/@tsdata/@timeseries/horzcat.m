function tsout = horzcat(ts1,varargin)
%HORZCAT  Horizontal concatenation of time series objects.
%
%   TS = HORZCAT(TS1,TS2,...) behaves identically to vertical
%   concatenation and performs
%
%         TS = [TS1 ; TS2 , ...]
% 
%   This operation amounts to appending the time series in 
%   the temporal direction. The time vecors must not overlap and
%   the size of the ordinate data sets must agree in all but the 
%   first dimension  
%
%   See also VERTCAT.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:33:46 $

% UDD will call horzcat with a single arg when using the syntax [t1;t2]
% proir to calling vertcat. Just echo the single input in thie case
if nargin==1
    tsout = ts1;
    return
end
warning('Timeseries concatenation is always performed along the time axis')
tsout = vertcat(ts1,varargin{:});









