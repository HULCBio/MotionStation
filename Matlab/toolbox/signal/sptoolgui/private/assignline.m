function [oh,lc] = assignline(lc,M,parent_ax,varargin)
%ASSIGNLINE  Assign lines from cache, or create new lines.
%   [oh,lc] = assignline(lc,data,parent_ax)
%   Inputs:
%      lc - line cache - vector of handles to line objects
%      M - number of lines to create / assign.
%      parent_ax - axes object handle which is the parent of lines
%          param/value pairs - for setting properties of any lines in oh
%   Outputs:
%      oh - vector of output handles
%      lc - line cache, updated
%
%   Used by sigbrowse and spectview

% Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if length(lc)>=M
    oh = lc(1:M);
    lc = lc(M+1:end);
else
    M=M-length(lc);
    oh = lc;
    lc = zeros(0,1);
    oh = [oh; line(zeros(2,M),zeros(2,M),'parent',parent_ax) ];
end
oh = oh(:);
if nargin>3
    set(oh,varargin{:})
end
lc = lc(:);
