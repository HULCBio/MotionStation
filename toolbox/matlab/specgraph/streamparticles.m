function hout = streamparticles(varargin)
%STREAMPARTICLES  Display stream particles.
%   STREAMPARTICLES(VERTICES) draws stream particles of a vector
%   field. Stream particles are usually represented by markers and
%   can show the position and velocity of a streamline. VERTICES
%   is a cell array of 2D or 3D vertices (as if produced by STREAM2
%   or STREAM3).
%
%   STREAMPARTICLES(VERTICES, N) uses N to determine how many
%   stream particles are drawn. The 'ParticleAlignment' property
%   controls how N is interpreted. If 'ParticleAlignment' is 'off'
%   (the default) and N is greater than 1, then approximately N
%   particles are drawn evenly spaced over the streamline vertices;
%   if N is less than or equal to 1, N is interpreted as a fraction
%   of the original stream vertices; for example, if N is 0.2,
%   approximately 20% of the vertices will be used.  N determines
%   the upper bound for the number of particles drawn. Note that 
%   the actual number of particles may deviate from N by as much 
%   as a factor of 2. If 'ParticleAlignment' is 'on', N determines
%   the number of particles on the streamline with the most
%   vertices; the spacing on the other streamlines is set to this
%   value. The default value is N=1.    
%
%   STREAMPARTICLES(...,'NAME1',VALUE1,'NAME2',VALUE2,...) controls
%   the stream particles by using named properties and specified
%   values.  Any unspecified properties have default values.  Case
%   is ignored for property names. 
%
%STREAMPARTICLES PROPERTIES
%    
%Animate - Stream particles motion [ non-negative integer ]
%   The number of times to animate the stream particles. The
%   default is 0 which does not animate. Inf will animate until
%   ctrl-c is hit.
%
%FrameRate - Animation frames per second [ non-negative integer ] 
%   The number of frames per second for the animation. Inf, the
%   default will draw the animation as fast as possible. Note: the
%   framerate can not speed up an animation.
%
%ParticleAlignment - Align particles with streamlines [ on | {off} ] 
%   Set this property to 'on' to force particles to be drawn at the
%   beginning of the streamlines. This property controls how N is
%   interpreted. 
%
%Also, any line property/value pairs such as 'erasemode' or
%   'marker' can be used.  The following is the default list of 
%   line properties set by STREAMPARTICLES. These can be overridden
%   by passing in property/value pairs.
%
%   Property           Value
%   --------           -----
%   'EraseMode'        'xor'
%   'LineStyle'        'none'
%   'Marker'           'o'
%   'MarkerEdgeColor'  'none'
%   'MarkerFaceColor'  'red'
%
%   STREAMPARTICLES(H,...) uses the LINE object H to draw the
%   stream particles. 
%
%   STREAMPARTICLES(AX,...) plots into AX instead of GCA.  This option is
%   ignored if you specify H as well.
%
%   H = STREAMPARTICLES(...) returns a vector of handles to LINE
%   objects.
%
%   Example 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:1:55, 5);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      sl = streamline(verts);
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.025);
%      axis tight; view(30,30); daspect([1 1 .125])
%      set(gca, 'drawmode', 'fast')
%      camproj perspective; box on
%      camva(44); camlookat; camdolly(0,0,.4, 'f');
%      h = line; 
%      streamparticles(h, iverts, 35, 'animate', 10, ...
%                      'ParticleAlignment', 'on');
%
%   Example 2:
%      load wind
%      daspect([1 1 1]); view(2)
%      [verts averts] = streamslice(x,y,z,u,v,w,[],[],[5]); 
%      sl = streamline([verts averts]);
%      axis tight off;
%      set(sl, 'linewidth', 2, 'color', 'r', 'vis', 'off')
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.05);
%      set(gca,'drawmode','fast','position',...
%              [0 0 1 1],'zlim',[4.9 5.1]);
%      set(gcf, 'color', 'k')
%      h = line; 
%      streamparticles(h, iverts, 200, ...
%                      'animate', 100, 'framerate',40, ...
%                      'markers', 10, 'markerf', 'y');
%
%   See also INTERPSTREAMSPEED, STREAMLINE, STREAM3, STREAM2.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/10 23:32:23 $

[cax,args,nargs] = axescheck(varargin{:});
[h, verts, n, animate, framerate, partalign, props] = ...
    parseargs(nargs, args);

% Set default values
if isempty(n)
  n = 1;
end

if isempty(animate)
  animate = 0;
end

if isempty(framerate)
  framerate = inf;
end
framerate = 1/framerate;

if isempty(partalign)
  partalign = 'off';
end

% Create a line if needed
if isempty(h)
  if isempty(cax)
    cax = gca;
  end
  h = line(nan,nan,'parent',cax);
else
  cax = ancestor(h,'axes');
end
set(h, 'linestyle', 'none', 'erasemode', 'xor', 'marker', 'o', ...
       'markeredgecolor', 'none', 'markerfacecolor', 'red');
  
if ~isempty(props)
  set(h, props)
end

% if it's 2D, make it 3D
vv=cat(1, verts{:});
if size(vv,2)==2
  vv(:,3) = 0;
end

if strcmp(partalign, 'off')
  % Evenly distributed particles
  len = size(vv,1);
  if n<=1
    n = n*len;
  end
  inc = ceil(len/n);

  set(h, 'xdata', vv(1:inc:end,1), ...
	 'ydata', vv(1:inc:end,2), ...
	 'zdata', vv(1:inc:end,3))
  for j = 1:animate
    for k = 1:inc;
      if framerate>0
	t0 = clock;
	while(etime(clock,t0)<framerate);end;
      end
      set(h, 'xdata', vv(k:inc:end,1), ...
	     'ydata', vv(k:inc:end,2), ...
	     'zdata', vv(k:inc:end,3))
      drawnow;
    end
  end
  
else
  % Particles aligned with start of streamlines
  lengths = cellfun('size', verts,1);
  %for j = 1:length(verts)
  %  lengths(j) = size(verts{j},1);
  %end
  endpos = cumsum(lengths);
  startpos = [1 endpos(1:end-1)+1];
  inc = ceil(max(lengths)/n);
  index = [];
  for j = 1:length(startpos)
    index = [index startpos(j):inc:endpos(j)];
  end
  set(h, 'xdata', vv(index,1), ...
	 'ydata', vv(index,2), ...
	 'zdata', vv(index,3))
  
  for i = 1:animate
    for k = 1:inc
      index = [];
      for j = 1:length(startpos)
	t0 = clock;  
	index = [index startpos(j)+k:inc:endpos(j)];
      end
      if framerate>0
	while(etime(clock,t0)<framerate);end; 
      end
      set(h, 'xdata', vv(index,1), ...
	     'ydata', vv(index,2), ...
	     'zdata', vv(index,3))
      drawnow;
    end
  end
  
end

if nargout > 0
  hout = h;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h, verts, n, animate, framerate, partalign, props] = parseargs(nin, vargin)

h = [];
verts = [];
n = [];
animate = [];
framerate = [];
partalign = [];
props = [];


if nin==0
  error('Wrong number of input arguments.'); 
else    % streamparticles(h,...) or streamparticles(verts) or streamparticles(verts,n)
  h = vargin{1};
  if ishandle(h) & strcmp(get(h, 'type'), 'line')
    nin = nin-1;
    vargin = vargin(2:end);
  else
    h = [];
  end
  verts = vargin{1};
  
  if nin>=2   % param value pairs
    if isstr(vargin{2})
      pos = 2;
    else
      n = vargin{2};
      pos = 3;
      if nin==3
	error('Wrong number of input arguments.'); 
      end
    end
    
    while pos<nin
      pname = lower(vargin{pos});
      if ~isstr(pname)
	error('First element of property value pairs must be a string');
      end
      if pos+1>nin
	error('Missing value in property value pair.');
      end
      pval = vargin{pos+1};
      
      if strcmp(pname, 'animate')
	animate = pval;
      elseif strcmp(pname, 'framerate')
	framerate = pval;
      elseif strcmp(pname, 'particlealignment')
	partalign = lower(pval);
      else
	props.(pname) = pval;
      end
      pos = pos+2;
    end
  end
end

