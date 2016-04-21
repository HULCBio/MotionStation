function h=surfc(varargin)
%SURFC  Combination surf/contour plot.
%   SURFC(...) is the same as SURF(...) except that a contour plot
%   is drawn beneath the surface.
%
%   See also SURF, SHADING.

%   Clay M. Thompson 4-10-91
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2002/10/24 02:14:32 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

[reg, prop]=parseparams(args);
nargs=length(reg);

error(nargchk(1,4,nargs));
if rem(length(prop),2)~=0,
   error('Property value pairs expected.')
end

if nargs==1,  % Generate x,y matrices for surface z.
  z = reg{1};
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);

elseif nargs==2,
  [z,c] = deal(reg{1:2});
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);
  
elseif nargs==3,
   [x,y,z]=deal(reg{1:3});
   
elseif nargs==4,
   [x,y,z,c]=deal(reg{1:4});

end

if min(size(z))==1,
  error('The surface Z must contain more than one row or column.');
end

% Determine state of system
if isempty(cax)
    cax = gca;
end
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% Plot surface
hs=surf(cax,args{:});

hold(cax,'on');

a = get(cax,'zlim');

zpos = a(1); % Always put contour below plot.

% Get D contour data
[cc,hh] = contour3(cax,x,y,z);

%%% size zpos to match the data

for i = 1:length(hh)
        zz = get(hh(i),'Zdata');
        set(hh(i),'Zdata',zpos*ones(size(zz)));
end

if ~hold_state, set(cax,'NextPlot',next); end
if nargout > 0
    h = [hs; hh(:)];
end
