function h=legendinfo(varargin)
%LEGENDINFO creates the scribe legendinfo

%   Copyright 1984-2003 The MathWorks, Inc.
%   $  $  $  $

h = scribe.legendinfo;

% set properties
set(h,varargin{:});