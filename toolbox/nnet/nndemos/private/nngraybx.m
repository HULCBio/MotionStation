function nngraybx(x,y,w,h,f)
%NNGRAYBX Shaded gray box for Neural Network Toolbox GUI.

%  NNGRAYBX(X,Y,W,H,F)
%    X - Horizontal position.
%    Y - Vertical position.
%    W - Width.
%    H - Height.
%    F - Flag (default = 0).
%
%  If F is nonzero then the shaded box is filled with
%                     yellow transfer function names.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% DEFAULTS

if nargin < 5, f = 0; end

% DRAW BOX

grays = nngrays;
dh = h/length(grays);
for i=1:length(grays)
  patch(x+[0 w w 0],y+([0 0 1 1]+(i-1))*dh,grays(i,:),'edgecolor','none')
end

% DRAW NAMES

if f
  names = nntfnms;
  k = 1;
  for i=0:6
    for j=0:10
      xx = i*70+22;
      yy = j*36+20;
      if (xx > x) & (xx < x+w) & (yy > y) & (yy < y+h)
        text(xx,yy,names(k,:), ...
          'color',nnltyell, ...
          'fontname','geneva', ...
          'fontsize',10, ...
          'fontangle','italic');
      end
      k = rem(k,length(names))+1;
    end
  end
end
