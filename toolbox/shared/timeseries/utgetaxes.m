function axout = utgetaxes(fig,varargin)
%UTGETAXES
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:34:15 $

% Utility used by preprocessing to access the axes children matching
% various criteria
a = get(fig,'Children');
ax = findobj(a,'flat','Type','axes');
ap = findobj(a,'flat','Type','uipanel');
for k=1:length(ap)
    ax = [ax; findobj(get(ap(k),'children'),'Type', 'axes')];
end


if nargin >1
    axout = [];
    k = 1;
    for j=1:length(ax)
       if strcmp(get(ax(j),'Tag'),varargin{1})
          axout(k) = ax(j);
          k = k+1;
       end
    end
else
    axout = ax;
end
