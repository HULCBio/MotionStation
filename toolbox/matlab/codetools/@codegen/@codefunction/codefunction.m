function [hThis] = codefunction(varargin)

% Copyright 2003 The MathWorks, Inc.

hThis = codegen.codefunction;

if nargin>0
   for n = 1:2:length(varargin)
      set(hThis,varargin{n},varargin{n+1});  
   end
end
