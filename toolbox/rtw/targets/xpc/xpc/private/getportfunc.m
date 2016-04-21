function [port, num] = getportfunc(varargin)
% GETPORTFUNC xPC Target private function.

%   GETPORTFUNC looks at the arguments and returns the port if the first
%   argument is a double. Otherwise, the port is set to 0. This is
%   mainly for backward compatibility and should soon be removed. The
%   second argument returns the number of arguments "comsumed". If the
%   first arg was a double, it is used and num == 1. If it is a string, the
%   string is ignored, port is set to 0, and num == 0.


%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2003/10/02 17:06:17 $

port = 0;
num  = 0;

if nargin == 0
  error('xPCTarget:xpcgate', 'Too few args');
end

if isa(varargin{1}, 'char')
  name = varargin{1};
  return;
end

d1 = varargin{1};
num = 1;
if ~isa(d1, 'double') || numel(d1) ~= 1
  error('xPCTarget:xpcgate', 'Must specify port and name');
end

port = d1;
