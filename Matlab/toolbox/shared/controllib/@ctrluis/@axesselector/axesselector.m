function h = axesselector(size,varargin)
%AXESSELECTOR  Constructor for @axesselector class.
%
%   H = AXESSELECTOR(SIZE)

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:38 $

h = ctrluis.axesselector;
h.Size = size;
h.RowName = repmat({''},[size(1) 1]);
h.RowSelection = logical(ones(size(1),1));
h.ColumnName = repmat({''},[size(2) 1]);
h.ColumnSelection = logical(ones(size(2),1));

% User-specified properties (can be any prop EXCEPT Visible)
h.set(varargin{:});

% Construct GUI
build(h)

% Add other listeners
addlisteners(h)