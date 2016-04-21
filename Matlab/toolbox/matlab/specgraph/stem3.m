function hh = stem3(varargin)
%STEM3  3-D stem plot.
%   STEM3(Z) plots the discrete surface Z as stems from the xy-plane
%   terminated with circles for the data value.
%
%   STEM3(X,Y,Z) plots the surface Z at the values specified
%   in X and Y.
%
%   STEM3(...,'filled') produces a stem plot with filled markers.
%
%   STEM3(...,LINESPEC) uses the linetype specified for the stems and
%   markers.  See PLOT for possibilities.
%
%   STEM3(AX,...) plots into AX instead of GCA.
%
%   H = STEM3(...) returns a stem object.
%
%   Backwards compatibility
%   STEM3('v6',...) creates line objects instead of stemseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   See also STEM, QUIVER3.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.18.4.4 $  $Date: 2004/02/01 22:05:48 $

[v6,args] = usev6plotapi(varargin{:});

% version 6, use line primitives
if v6
  h = Lstem3v6(args{:});
  
% version 7, use stem wrapper object 
else
    
  % make sure first arg is an axes  
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs));
  
  % pull out param value pairs
  [pvpairs,args,nargs,msg] = parseargs(args, nargs);
  if ~isempty(msg), error(msg); end
  error(nargchk(1,3,nargs));
  
  % create xdata,ydata if necessary
  [msg,x,y,z] = xyzchk(args{1:nargs});
  if ~isempty(msg), error(msg); end
    
  % 'hold on' support
  cax = newplot(cax);
  next = lower(get(cax,'NextPlot'));
  hold_state = ishold(cax);
  
  h = []; 
  autoColor = ~any(strcmpi('color',pvpairs(1:2:end)));
  autoStyle = ~any(strcmpi('linestyle',pvpairs(1:2:end)));

  % Reshape to vectors
  x = reshape(x,[1,prod(size(x))]);
  y = reshape(y,[1,prod(size(y))]);
  z = reshape(z,[1,prod(size(z))]);
  datapairs = {'XData',x,'YData',y,'ZData',z};
  
  [l,c,m] = nextstyle(cax,autoColor,autoStyle,true);
  if ~isempty(m) && ~strcmp(m,'none')
    pvpairs =  {'Marker',m,pvpairs{:}};
  end
  h = specgraph.stemseries(datapairs{:},...
                           'Color',c,'LineStyle',l,...
                           pvpairs{:},'parent',cax);
    
  % flag code generation properties
  if autoColor
     set(h,'CodeGenColorMode','auto');
  end
  if autoStyle
    set(h,'CodeGenLineStyleMode','auto');
  end
  if ~any(strcmpi('marker',pvpairs(1:2:end)))
    set(h,'CodeGenMarkerMode','auto');
  end
  set(h,'refreshmode','auto');
  h = double(h);
 
  % 3-D view
  if ~ishold(cax), view(cax,3); grid(cax,'on'); end
  
  % hold support
  if ~hold_state, set(cax,'NextPlot',next); end

end 

if nargout>0, hh = h; end

%--------------------------------------------------%
function [pvpairs,args,nargs,msg] = parseargs(args,nargs)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
n = 1;
extrapv = {};

% Loop through args, check for 'filled' or LINESPEC
while length(pvpairs) >= 1 && n < 4 && isstr(pvpairs{1})
  arg = lower(pvpairs{1});
  
  % 'filled'
  if arg(1) == 'f'
    pvpairs(1) = [];
    extrapv = {'MarkerFaceColor','auto',extrapv{:}};
    
  % LINESPEC (i.e. 'r*')   
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = {'linestyle',l,extrapv{:}};
      end
      if ~isempty(c)
        extrapv = {'color',c,extrapv{:}};
      end
      if ~isempty(m)
        extrapv = {'marker',m,extrapv{:}};
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);

%--------------------------------------------------%
function hh = Lstem3v6(varargin)
[cax,args,nargs] = axescheck(varargin{:});
nin = nargs;

fill = 0;
ls = '-';
ms = 'o';
col = '';

% Parse the string inputs
while isstr(args{nin}),
  v = args{nin};
  if ~isempty(v) & strcmp(lower(v(1)),'f')
    fill = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(v);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',v));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; end
    nin = nin-1;
  end
end

error(nargchk(1,3,nin));

[msg,x,y,z] = xyzchk(args{1:nin});
if ~isempty(msg), error(msg); end

qargs = {x,y,z,zeros(size(x)),zeros(size(x)),-z,0,[col,ls,ms]};

if fill,  
    qargs = {qargs{:},'filled'}; 
end
if ~isempty(cax)
    qargs = {cax,qargs{:}};
end
h = quiver3('v6',qargs{:});

if nargout>0, hh = h; end
