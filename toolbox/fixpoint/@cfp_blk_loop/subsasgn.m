function out=subsasgn(varargin)
%SUBSASGN subscripted assignment

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:03 $

% this function causes all of the object's fields to be public

out=builtin('subsasgn',varargin{:});
