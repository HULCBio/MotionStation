function out=subsasgn(varargin)
%SUBSASGN Subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:30 $

% this function causes all of the object's fields to be public

out=builtin('subsasgn',varargin{:});
