function hh = ezplot3(varargin)
%EZPLOT3  Easy to use 3-d parametric curve plotter.
%   EZPLOT3(x,y,z) plots the spatial curve x = x(t), y = y(t),
%   and z = z(t) over the default domain 0 < t < 2*pi.
%
%   EZPLOT3(x,y,z,[tmin,tmax]) plots the curve x = x(t), y = y(t),
%   and z = z(t) over tmin < t < tmax.
%
%   EZPLOT3(x,y,z,'animate') or EZPLOT(x,y,z,[tminm,tmax],'animate')
%   produces an animated trace of the spatial curve.
%
%   EZPLOT3(AX,...) plots into AX instead of GCA.
%
%   H = EZPLOT3(...) returns handles to the plotted objects in H.
%
%   Examples:
%     The functions x, y, and z can be specified using @, an inline
%     object, or an expression.  M-file functions and inline functions
%     must be written to accept vector inputs:
%        fy = @(t)t .* sin(t);
%        ezplot3(@cos, fy, @sqrt)
%        ezplot3('cos(t)', 't * sin(t)', 'sqrt(t)', [0,6*pi])
%        ezplot3(@cos, fy, @sqrt, 'animate')
%
%  See also EZPLOT, EZSURF, EZPOLAR, PLOT, PLOT3

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.4 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

% Create plot 
cax = newplot(cax);
fig = ancestor(cax,'figure');

% Check each input function or expression
[x,x0,xargs] = ezfcnchk(args{1},0,'t');
[y,y0,yargs] = ezfcnchk(args{2},0,'t');
[z,z0,zargs] = ezfcnchk(args{3},0,'t');

allargs = union(xargs,union(yargs,zargs));
numargs = length(allargs);
if (ismember({''},allargs)), numargs = max(1, numargs-1); end
if (numargs == 2)
   error('To plot parametrized surfaces, use EZSURF')
elseif (numargs > 2)
   error('Functions must take one argument.');
end

Aflag = 0; % Animation option.

Npts = 300;

% Determine the domain in t:
switch nargs
   case 3
      T =  linspace(0,2*pi,Npts);
   case 4
      if isa(args{4},'double')   
         T = linspace(args{4}(1),args{4}(2),Npts);
      elseif isequal(args{4},'animate')
         Aflag = 1;
         T =  linspace(0,2*pi,Npts);
      else
         T =  linspace(0,2*pi,Npts);
      end
   case 5
      if isa(args{4},'double') & isequal(args{5},'animate') 
         T = linspace(args{4}(1),args{4}(2),Npts);
         Aflag = 1;
      elseif isequal(args{4},'animate') & isa(args{5},'double')
         T = linspace(args{5}(1),args{5}(2),Npts);
         Aflag = 1;
      else
         T = linspace(0,2*pi,Npts);
      end
end

H = findobj(fig,'Type','uicontrol','String','Repeat');
if ~isempty(H) & ~Aflag
   delete(H);
end

% Evaluate each of (X,Y,Z)
X = ezplotfeval(x,T);
if prod(size(X)) == 1
   X = X*ones(size(T));
end
Y = ezplotfeval(y,T);
if prod(size(Y)) == 1
   Y = Y*ones(size(T));
end
Z = ezplotfeval(z,T);
if prod(size(Z)) == 1
   Z = Z*ones(size(T));
end

% Option to Return a handle.
h = plot3(X,Y,Z,'parent',cax);

xlabel(cax,'x'); ylabel(cax,'y'); zlabel(cax,'z');
title(cax,['x = ' texlabel(x0), ', y = ' texlabel(y0), ', z = ' texlabel(z0)]);
grid(cax,'on');

if Aflag
   hold(cax,'on');
   H = plot3(X(1),Y(1),Z(1),'r.','erasemode','xor','markersize',24,'parent',cax);

   dk = ceil(length(Y)/Npts);
   % run once with timing so that we see how fast this machine is
   tic
   set(H,'xdata',X(1),'ydata',Y(1),'zdata',Z(1));
   drawnow;
   tm = 0.00003/toc;
   for k = 2:dk:length(Y)
      set(H,'xdata',X(k),'ydata',Y(k),'zdata',Z(k));
      pause(tm);
      drawnow;
   end
   % Define the userdata for the callback.
   ud.x = X; ud.y = Y; ud.z = Z; ud.dk = dk; ud.h = H; ud.tm = tm; ud.cax = cax;
   set(fig,'userdata',ud);
   % Define the callback string.
   s = ['ud = get(gcbf,''userdata'');' ...
        'hold(ud.cax,''on'');' ...
        'tm = ud.tm;' ...
        'for k = 1:ud.dk:length(ud.y),' ...
           'set(ud.h,''xdata'',ud.x(k),''ydata'',ud.y(k),''zdata'',ud.z(k));' ...
           'pause(tm);' ...
           'drawnow;' ...
        'end,' ...
        'hold(ud.cax,''off'');'];
   uicontrol('Units','normal','Position',[.02 .01 .1 .06], ...
             'String','Repeat','CallBack',s,'parent',fig);

end

if nargout > 0
    hh = h;
end