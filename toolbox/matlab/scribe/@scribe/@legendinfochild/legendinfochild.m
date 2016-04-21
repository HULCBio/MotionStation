function h=legendinfochild(varargin)
%LEGENDINFOCHILD creates the scribe legendinfochild

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $

h = scribe.legendinfochild;

% set properties
set(h,varargin{:});