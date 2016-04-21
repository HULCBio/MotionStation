function [hThis] = codeblock(varargin)

% Copyright 2003 The MathWorks, Inc.

hThis = codegen.codeblock;

if nargin>0
   for n = 1:2:length(varargin)
      set(hThis,varargin{n},varargin{n+1});  
   end
end
