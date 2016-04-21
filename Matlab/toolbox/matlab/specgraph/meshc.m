function h=meshc(varargin)
%MESHC  Combination mesh/contour plot.
%   MESHC(...) is the same as MESH(...) except that a contour plot
%   is drawn beneath the mesh.
%
%   Because CONTOUR does not handle irregularly spaced data, this 
%   routine only works for surfaces defined on a rectangular grid.
%   The matrices or vectors X and Y define the axis limits only.
%
%   See also MESH, MESHZ.

%   Clay M. Thompson 4-10-91
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2002/10/24 02:14:07 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

error(nargchk(1,4,nargs));

if nargs==1,  % Generate x,y matrices for surface z.
    z = args{1};
    [m,n] = size(z);
    [x,y] = meshgrid(1:n,1:m);
    
elseif nargs==2,
    z = args{1}; c = args{2};
    [m,n] = size(z);
    [x,y] = meshgrid(1:n,1:m);
    
else
    [x,y,z] = deal(args{1:3});
    if nargs==4
        c = args{4};
    end
    
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

% Plot mesh.
if nargs==2 | nargs==4,
    hm=mesh(cax,x,y,z,c);
else
    hm=mesh(cax,x,y,z);
end

hold(cax,'on');

a = get(cax,'zlim');

zpos = a(1); % Always put contour below the plot.

% Get D contour data
[cc,hh] = contour3(cax,x,y,z);

%%% size zpos to match the data

for i = 1:length(hh)
    zz = get(hh(i),'Zdata');
    set(hh(i),'Zdata',zpos*ones(size(zz)));
end

if ~hold_state, set(cax,'NextPlot',next); end
if nargout > 0
    h = [hm; hh(:)];
end
