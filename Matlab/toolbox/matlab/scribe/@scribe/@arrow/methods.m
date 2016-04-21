function val = methods(this,fcn,varargin)
% METHODS - methods for arrow class

%   Copyright 1984-2003 The MathWorks, Inc. 

val = [];
% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end
subfunctions = {'mouseover','postdeserialize','updateXYData', ...
                'ispointon'};
if any(strcmp(fcn,subfunctions))
  args = {fcn,this,varargin{:}};
  if nargout == 0
    feval(args{:});
  else
    val = feval(args{:});
  end
else
  if nargout == 0
    lineMethods(this,fcn,varargin{:});
  else
    val=lineMethods(this,fcn,varargin{:});
  end
end

%-----------------------------------------------------------------------%
function over=mouseover(h,point)
% Return the cursor to use if the mouse is over this object.
scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
obj = hittest(fig);
over = 0; % not over object

if strcmpi('off',scribeax.InteractiveCreateMode)
    if ishandle(obj)
        [inhead,intail,inaff] = parts_containing_point(h,obj);
        if inaff>0 
            over = 'movepoint'; % move endpoint
        elseif inhead>0 || intail>0
            over = 1; % move object
        end
    end
end

%-----------------------------------------------------------------------%
function on=ispointon(h,point)

on=false;
fig = ancestor(double(h),'figure');
obj = hittest(fig);
[inhead,intail,inaff] = parts_containing_point(h,obj);
% if selected need to consider affordances too
if inhead>0 || intail>0 || (isequal(h.Selected,'on') && inaff>0)
    on=true;
end

%-----------------------------------------------------------------------%
function [inhead,intail,inaff] = parts_containing_point(h,obj)

% initial values
inhead=0;
inaff=0;
intail=0;

if isequal(obj,double(h.Tail))
    intail=1;
    return;
elseif isequal(obj,double(h.Srect(1)))
    inaff=1;
    return;
elseif isequal(obj,double(h.Srect(2)))
    inaff=2;
    return;
elseif isequal(obj,double(h.Heads))
    inhead=1;
    return;
end

%-----------------------------------------------------------------------%
function postdeserialize(h)

% delete children not created in constructor and children involved in
% pinning (Pintext, Pinrect).
goodchildren(1) = double(h.Tail);
goodchildren(2:3) = double(h.Srect);
goodchildren(4) = double(h.Heads);
allchildren = get(double(h),'Children');
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
    delete(badchildren);
end
methods(h,'updateXYData');
%{
% repin head 1 if it was pinned
if ~isempty(h.PinnedAxes1) || ~isempty(h.PinnedObject1)
    h.PinnedAxes1 = [];
    h.PinnedObject1 =[];
    methods(h,'pin_at_current_position',1);
end
% repin head 2 if it was pinned
if ~isempty(h.PinnedAxes2) || ~isempty(h.PinnedObject2)
    h.PinnedAxes2 = [];
    h.PinnedObject2 =[];
    methods(h,'pin_at_current_position',2);
end
%}
% set deselected (no saving selected)
methods(h,'setselected','off');

%-----------------------------------------------------------------------%
function updateXYData(h)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');

% Get pixel position of overlay ax
ppos = scribeax.methods('getpointpos');

R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','points',fig);
R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','points',fig);
PX = [R1(3) R2(3)];
PY = [R1(4) R2(4)];

% Angle of arrow
dx = PX(2) - PX(1);
dy = PY(2) - PY(1);
theta = atan2(dy,dx);
costh = cos(theta);
sinth = sin(theta);
% length of whole arrow in points
PAL = sqrt((abs(PX(1) - PX(2)))^2 + (abs(PY(1) - PY(2)))^2);

% unrotated x,y,z vectors for line part
x1 = 0;
L = h.HeadLength;
switch (h.HeadStyle)
    case 'none'
        x2 = PAL;
    case {'plain','diamond','fourstar','ellipse','rectangle','rose'}
        x2 = PAL - L;
    case {'vback1','vback2','vback3'}
        d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};        
        x2 = PAL - (1 - d(find(strcmp(b,h.HeadStyle))))*L;
    case {'cback1','cback2','cback3'}
        d = [.1,.25,.6]; b = {'cback1','cback2','cback3'}; 
        depth = d(find(strcmp(b,h.HeadStyle)));
        dfromend = (1 - depth)*(L/PAL);
        x2 = PAL*(1 - dfromend);
    case 'hypocycloid'
        N = h.HeadHypocycloidN;
        % odd number doesn't get rotated
        % already points away (with a -1*x flip at this end)
        % meets tail in one of its concavities
        if mod(N,2)>0
            x2 = PAL - (((N-1)/N)*L);
        else
            x2 = PAL - L;
        end
    case 'astroid'
        x2 = PAL - L;
    case 'deltoid'
        x2 = PAL - (2*L/3);
end

x = [x1,x2];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + PX(1);
yy = x.*sinth + y.*costh + PY(1);
% convert to normalized
if ppos(3)>0 & ppos(4)>0
    xx = xx ./ ppos(3);
    yy = yy ./ ppos(4);
end
set(double(h.Tail),'xdata',xx,'ydata',yy);

% unrotated x,y,z vectors for arrow head
L = h.HeadLength;
W = h.HeadWidth/2;
switch (h.HeadStyle)
    case 'plain'
        x = [PAL-L, PAL, PAL-L];
        y = [W, 0, -W];
    case {'vback1','vback2','vback3'}
        narrowfrx = .75;
        d = [.15,.35,.8]; b = {'vback1','vback2','vback3'}; 
        depth = d(find(strcmp(b,h.HeadStyle)));
        x = [PAL-L, PAL, PAL-L, PAL - (1 - depth)*L, PAL-L];
        y = narrowfrx.*[W, 0, -W, 0, W];
    case 'diamond'
        x = [PAL-L/2, PAL, PAL-L/2, PAL-L];
        y = [W, 0, -W, 0];
    case 'rectangle'
        x = [PAL-L, PAL, PAL, PAL-L];
        y = [W, W, -W, -W];
    case 'fourstar'
        x = [PAL-L/2, PAL-L/3, PAL, PAL-L/3, PAL-L/2, PAL-(2*L/3), PAL-L, PAL-(2*L/3)];
        y = [W, W/3, 0, -W/3, -W, -W/3, 0, W/3];
    case {'cback1','cback2','cback3'}
        d = [.1,.25,.6]; b = {'cback1','cback2','cback3'}; 
        depth = d(find(strcmp(b,h.HeadStyle)));
        y = pi/2:pi/40:3*pi/2;
        X = cos(y);
        y = [y, 3*pi/2, pi, pi/2];
        xbot = -3;
        xoff = 2*depth;
        x = xoff.*X;
        x = [x, 0 xbot 0];
        % flip around
        x = -x;
        % and pi/2 to 3pi/2 in y
        y = y./pi - 1; %-1/2 to 1/2
        y = y.*2*W; %-W to W
        x = x.*(L/3);
        x = x + PAL - L;
    case 'ellipse'
        % make a basic ellipse LxW at 0,0 with 20 points
        for i=1:40
            th = i*pi/20;
            x(i) = L/2 * cos(th);
            y(i) = W * sin(th);
        end
        % translate to beginning of arrow
        x = x + PAL - L/2;
    case 'rose'
        % Roses r==Cos[p/q*theta]. 
        % Parametric: Cos[p/q*t]*{Cos[t],Sin[t]}
        pq = h.HeadRosePQ;
        t=0:pi/40:2*pi;
        x=sin(t).*cos(pq*t)*L/2;
        y=cos(t).*cos(pq*t)*W;
        x = x + PAL - L/2;
    case 'hypocycloid'
        N = h.HeadHypocycloidN;
        a = 1;
        b = 1/N;
        t=0:pi/(6*N):2*pi;
        x = (a - b) * cos(t) - b*cos(((a-b)/b)*t);
        y = (a - b) * sin(t) + b*sin(((a-b)/b)*t);
        if mod(N,2)==0
            % a little rotation for even pointed hypocycloids
            % so that point meets tail.
            phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
            xx = x.*cosphi - y.*sinphi;
            yy = x.*sinphi + y.*cosphi;
            x = xx;
            y = yy;
        else
            % odd pointed hypocycloids need to be flipped for
            % concavity to meet tail and point to point away.
            x = -x;
        end
        x = x*L/2;
        y = y*W;
        x = x + PAL - L/2;
    case 'astroid' %hypocycloid, N=4;
        N = 4;
        a = 1;
        b = 1/N;
        t=0:pi/24:2*pi;
        x = (a - b) * cos(t) - b*cos(((a-b)/b)*t);
        y = (a - b) * sin(t) + b*sin(((a-b)/b)*t);
        % a little rotation for even pointed hypocycloids
        % so that point meets tail.
        phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
        xx = x.*cosphi - y.*sinphi;
        yy = x.*sinphi + y.*cosphi;
        x = xx;
        y = yy;
        x = x*L/2;
        y = y*W;
        x = x + PAL - L/2;
    case 'deltoid' %hypocycloid, N=3;
        N = 3;
        a = 1;
        b = 1/N;
        t=0:pi/18:2*pi;
        x = (a - b) * cos(t) - b*cos(((a-b)/b)*t);
        y = (a - b) * sin(t) + b*sin(((a-b)/b)*t);
        % odd pointed hypocycloids need to be flipped for
        % concavity to meet tail and point to point away.
        x = -x;
        x = x*L/2;
        y = y*W;
        x = x + PAL - L/2;
    case 'none'
        x = PAL; y = 0;
end   
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + PX(1);
yy = x.*sinth + y.*costh + PY(1);
% Update Head 2 xdata and ydata.
if ppos(3)>0 & ppos(4)>0
    xx = xx ./ ppos(3);
    yy = yy ./ ppos(4);
    set(double(h.Heads),'xdata',xx,'ydata',yy,'zdata',zeros(length(yy),1));
end
h.setidentity;

%----------------------------------------------------------------%