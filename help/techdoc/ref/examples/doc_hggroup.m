function doc_hggroup
% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Hggroup example

% Copyright 2003-2004 The MathWorks, Inc.

hg = hggroup('ButtonDownFcn',@set_lines);
hl  = line(randn(5),randn(5),'HitTest','off','Parent',hg);

function set_lines(cb,eventdata)
hl = get(cb,'Children');% cb is handle of hggroup object
lw = get(hl,'LineWidth');% get current line widths
set(hl,{'LineWidth'},num2cell([lw{:}]+1,[5,1])')
