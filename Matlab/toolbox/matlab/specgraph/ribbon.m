function hh = ribbon(varargin)
%RIBBON Draw 2-D lines as ribbons in 3-D.
%   RIBBON(X,Y) is the same as PLOT(X,Y) except that the columns of
%   Y are plotted as separated ribbons in 3-D.  RIBBON(Y) uses the
%   default value of X=1:SIZE(Y,1).
%
%   RIBBON(X,Y,WIDTH) specifies the width of the ribbons to be
%   WIDTH.  The default value is WIDTH = 0.75;  
%
%   RIBBON(AX,...) plots into AX instead of GCA.
%
%   H = RIBBON(...) returns a vector of handles to surface objects.
%
%   See also PLOT.

%   Clay M. Thompson 2-8-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2002/10/24 02:14:18 $

error(nargchk(1,inf,nargin));
[cax,args,nargs] = axescheck(varargin{:});

% Parse input arguments.
if nargs<3, 
  width = .75;
  [msg,x,y] = xychk(args{1:nargs},'plot');
else
  width = args{3};
  [msg,x,y] = xychk(args{1:2},'plot');
end

if ~isempty(msg), error(msg); end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

[m,n] = size(y);
zz = [-ones(m,1) ones(m,1)]/2;
h = [];
cc = ones(size(y,1),2);
for i=1:size(y,2),
  h = [h;surface(zz*width+i,[x(:,i) x(:,i)],[y(:,i) y(:,i)],i*cc,'parent',cax)];
end

if ~hold_state, view(cax,3); grid(cax,'on'), set(cax,'NextPlot',next); end

if nargout>0, hh = h; end

