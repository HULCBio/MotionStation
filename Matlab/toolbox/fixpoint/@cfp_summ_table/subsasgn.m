function out=subsasgn(varargin)
%SUBSASGN

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:55:57 $

% this function causes all of the object's fields to be public

out=builtin('subsasgn',varargin{:});
