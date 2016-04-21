function varargout = CheckArraySize(varargin)
%CHECKARRAYSIZE  Checks and harmonizes array dimensions.
%
%   [SYS1,..,SYSN] = CHECKARRAYSIZE(SYS1, ...,SYSN) checks that
%   array sizes are compatible and expands singleton dimensions.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/11/11 22:21:36 $

% Acquire sizes and max array size
s = cell(size(varargin));
smax = [1 1];
for k=1:length(varargin)
   sk = size(varargin{k});
   sk = [sk(3:end) , ones(1,4-length(sk))];
   ndd = length(smax)-length(sk);
   smax = max([smax ones(1,-ndd);sk ones(1,ndd)]);
   s{k} = sk;
end

% Harmonize sizes
for k=1:length(varargin)
   if all(s{k}==1)
      % Scalar expand
      varargin{k} = repsys(varargin{k},[1 1 smax]);
   elseif ~isequal(s{k},smax)
      error('System arrays must have compatible dimensions.')
   end
end

varargout = varargin;