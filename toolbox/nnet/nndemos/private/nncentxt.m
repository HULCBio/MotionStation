function h = nncentxt(s)
% NNCENTXT Neural Network Design utility function.

%    NNCENTXT(S)
%    S - String.
%    Displays string S in current axis, and returns handle.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.6 $

if nargin == 0, s = 'Neuro-Waffle'; end

x = get(gca,'xlim');
y = get(gca,'ylim');
h = text(sum(x)*0.5,sum(y)*0.5,s);
set(h,'horizontal','center');
set(h,'fontweight','bold');

