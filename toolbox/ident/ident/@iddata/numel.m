function nel = numel(dat,varargin)
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $ $Date: 2004/04/10 23:16:03 $

if nargin>1
    % DAT{IDX} syntax disabled
    error('Syntax DATA{...} is no longer supported. Use GETEXP or MERGE instead.')
else
    nel = 1;
end