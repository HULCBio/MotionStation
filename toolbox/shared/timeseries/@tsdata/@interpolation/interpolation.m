function  h = interpolation(varargin)
%INTERPOLATION Constructor for interpolation objects
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:18 $

nargchk(0,1,nargin);
h = tsdata.interpolation;

if nargin>=1 && ischar(varargin{1}) 
   set(h,'fhandle',{@tsinterp varargin{1}},'Name',varargin{1});
end
