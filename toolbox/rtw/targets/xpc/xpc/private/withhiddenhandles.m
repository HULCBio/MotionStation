function output = withhiddenhandles(varargin)
% WITHHIDDENHANDLES xPC Target private function.

% WITHHIDDENHANDLES Set ShowHiddenHandles on temporarily & feval arguments.
%
%   This evaluates the input arguments while turning ShowHiddenHandles to
%   'on'. The old value of ShowHiddenhandles is remembered and restored.
%   The evaluation is done using feval, so the first argument must be a
%   function name.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/03/20 15:46:51 $

f = str2func(varargin{1});
hidden = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');
output = feval(f, varargin{2 : end});
set(0, 'ShowHiddenHandles', hidden);