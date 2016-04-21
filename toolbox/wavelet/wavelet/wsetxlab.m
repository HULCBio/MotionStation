function wsetxlab(axe,strxlab,col,vis)
%WSETXLAB Plot xlabel.
%    WSETXLAB(AXE,STRXLAB,COL,VIS)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10 $

xlab = get(axe,'Xlabel');
if nargin<4 , 
    vis = 'on';
    if nargin<3 , col = get(xlab,'Color'); end
end
set(xlab,...
        'String',strxlab, ...
        'Visible',vis, ...
        'FontSize',get(axe,'FontSize'),...
        'Color',col ...
        );
