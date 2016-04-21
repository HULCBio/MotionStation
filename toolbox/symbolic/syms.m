function syms(varargin)
%SYMS   Short-cut for constructing symbolic objects.
%   SYMS arg1 arg2 ...
%   is short-hand notation for
%      arg1 = sym('arg1');
%      arg2 = sym('arg2'); ...
%
%   SYMS arg1 arg2 ... real
%   is short-hand notation for
%      arg1 = sym('arg1','real');
%      arg2 = sym('arg2','real'); ...
%
%   SYMS arg1 arg2 ... positive
%   is short-hand notation for
%      arg1 = sym('arg1','positive');
%      arg2 = sym('arg2','positive'); ...
%
%   SYMS arg1 arg2 ... unreal
%   is short-hand notation for
%      arg1 = sym('arg1','unreal');
%      arg2 = sym('arg2','unreal'); ...
%
%   Each input argument must begin with a letter and must contain only
%   alphanumeric characters.
%
%   By itself, SYMS lists the symbolic objects in the workspace.
%
%   Examples:
%      syms x beta real
%   is equivalent to:
%      x = sym('x','real');
%      beta = sym('beta','real');
%
%      syms k positive
%   is equivalent to:
%      k = sym('k','positive');
%
%   To clear the symbolic objects x and beta of 'real' or 'positive' status, type
%      syms x beta unreal
%
%   See also SYM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/16 22:23:30 $

if nargin < 1
   w = evalin('caller','whos');
   k = strmatch('sym',char({w.class,''}));
   disp(' ')
   disp({w(k).name})
   disp(' ')
   return
end

n = prod(size(varargin));
for k = 1:n
   if ~isvarname(varargin{k})
      error('symbolic:sym:errmsg1','Not a valid variable name.')
   end
end
reals = strcmp(varargin{n},'real');
unreals = strcmp(varargin{n},'unreal');
pos = strcmp(varargin{n},'positive');
if (reals | unreals | pos), n = n-1; end
for k = 1:n
   x = varargin{k};
   if reals
      assignin('caller',x,sym(x,'real'));
   elseif unreals
      assignin('caller',x,sym(x,'unreal'));
   elseif pos
      assignin('caller',x,sym(x,'positive'));
   else
      assignin('caller',x,sym(x));
   end
end
