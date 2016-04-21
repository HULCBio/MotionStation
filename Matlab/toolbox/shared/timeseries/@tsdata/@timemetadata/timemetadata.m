function h = timemetadata(varargin)
%TIMEMEATDATA timemetadata constructor 
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:44 $

h = tsdata.timemetadata;
if nargin>=1
    h.Start = varargin{1};
end
if nargin>=2
    h.End = varargin{2};
end
if nargin>=3
    h.Length = varargin{3};
end

