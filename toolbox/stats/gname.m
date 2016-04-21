function hh=gname(cases,line_handle)
%GNAME  Labels plotted points with their case names or case number.
%   GNAME(CASES) displays the graph window, puts up a cross-hair, and
%   waits for a mouse button or keyboard key to be pressed.  You can
%   position the cross-hair with the mouse and click once near each
%   point to see a label on that point.  Alternatively you can drag
%   a selection rectangle to label all points in the rectangle.  Click
%   with the right mouse button to remove labels.  When you are done,
%   press the enter or escape key to stop labeling.  CASES can be a cell
%   array of strings, or a string array with each row being the case name
%   of a point.
%
%   GNAME with no arguments labels each case with its case number.  It
%   also uses the case number as a label if the number of names in CASES
%   does not match the number of points on the line you select.
%   
%   HH = GNAME(CASES,LINE_HANDLE) returns a vector of handles
%   to the text objects on the plot.  Use the scalar, LINE_HANDLE, to
%   specify a subset of the lines to label.  The default behavior
%   is to label all lines on the plot (except those with a line
%   style of '-', '--', or '-.' when there are multiple lines).
%
%   See also TEXT, GINPUT, RBBOX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.2.3 $  $Date: 2004/04/01 16:23:37 $

[az el] = view;
if az ~= 0 || el ~= 90
   error('stats:gname:BadView','View must be two-dimensional.');
end
if (nargin < 1), cases = []; end
if (nargin < 2), line_handle = []; end
a = findobj(gcf, 'Type', 'axes');
if (length(a) < 2)
   h=gnamesub(cases,line_handle);
else
   h = [];
   bigax = gca;
   set(gcf,'CurrentAx',bigax)
   [x0,y0,x1,y1] = ginput0(1);
   while(length(x0)>0)
      % Invoke subroutine with current axes set properly
      h0 = gnamesub(cases,line_handle,x0,y0,x1,y1);
      h = [h; h0(:)];
      % Get next mouse click
      set(gcf,'CurrentAx',bigax)
      [x0,y0,x1,y1] = ginput0(1);
   end
   set(gcf,'CurrentAx',bigax)
end

if nargout > 0
   hh = h(ishandle(h));
end

% ----------------------------------
function h=gnamesub(cases,line_handle,x0,y0,x1,y1)
% If no line handles supplied, get lines that appear to be plots of
% data rather than fits.  (See the lsline function.)
h = [];
if nargin < 2, line_handle=[]; end
patches = findobj(gca, 'Type','patch');
if (length(line_handle)==0 && length(patches)==0)
  line_handle = findobj(gca,'type','line');
  tmp = line_handle;
  for j=length(line_handle):-1:1
    style = get(line_handle(j),'LineStyle');
    if (strcmp(style,'-') || strcmp(style,'--') || strcmp(style,'-.'))
        line_handle(j) = [];
    end
  end
  if (length(line_handle)==0), line_handle = tmp; end
end 

nlines = length(line_handle);
if (nargin<1), cases = []; end
if iscell(cases)
   ncases = length(cases);
else
   ncases = size(cases,1);
end

% Get all (x,y) values that may be labeled
u = get(gca, 'UserData');
specialgraph = 0;          % from a special plotting function?
if (iscell(u))
   if (strcmp(u{1}, 'gscatter'))
      specialgraph = 1;
   elseif (strcmp(u{1}, 'boxplot'))
      specialgraph = 2;
   end
end
if (specialgraph == 1)
   % If from the gscatter function, userdata has useful information
   xdat = u{2};
   ydat = u{3};
   n = size(xdat,1);
   nx = size(xdat,2);
   ny = size(ydat,2);
   if (nx>1)
      ydat = repmat(ydat,nx);
      xdat = xdat(:);
   elseif (ny>1)
      xdat = repmat(xdat,ny);
      ydat = ydat(:);
   end
   casenums = repmat((1:n)', max(nx,ny), 1);
   if (n == ncases), casenums = -casenums; end
      
elseif (specialgraph == 2)
   % From the boxplot function
   ydat = u{2};
   xdat = u{3};
   vert = u{4};
   if isempty(xdat)
      if size(ydat,2)==1
         xdat = ones(size(ydat));
      else
         xdat = repmat(1:size(ydat,2),size(ydat,1),1);
         ydat = ydat(:);
         xdat = xdat(:);
      end
   end
   if ~isequal(vert,1) % swap x/y for horizontal boxes
      tmp = xdat;
      xdat = ydat;
      ydat = tmp;
   end
   n = size(ydat,1);
   casenums = (1:n)';
   if (n == ncases), casenums = -casenums; end
      
elseif (nlines == 0)
   % If from the scatter function, graph may have patches rather than lines.
   if (isempty(patches))
      error('stats:gname:NoLine','Did not find a line to label.');
   end
   par = get(patches(1),'Parent');
   if isequal(get(par,'Type'),'hggroup')
      % In R14 and beyond scatter patches are part of an hggroup
      xdat = get(par,'XData');
      ydat = get(par,'YData');
   else
      % The R13 method that may no longer be required
      xdat = get(patches,'XData');
      if (~iscell(xdat)), return; end
      xdat = cat(1,xdat{:});
      ydat = get(patches,'YData');
      ydat = cat(1,ydat{:});
      xdat = xdat(end:-1:1);    % note that child order is in reverse
      ydat = ydat(end:-1:1);
   end
   nx = length(xdat);
   if (nx == ncases)
      casenums = -1:-1:-nx;     % negative numbers to use values of cases
   else
      casenums = 1:nx;
   end
   
else
   xdat = get(line_handle,'XData');
   ydat = get(line_handle,'YData');
   if (nlines == 1)
      nx = length(xdat);
      if (nx == ncases)
         casenums = -(1:nx);
      else
         casenums = 1:nx;
      end
   else
      for j=1:nlines
         nx = length(xdat{j,1});
         if (nx == ncases)
            xdat{j,2} = -(1:nx);
         else
            xdat{j,2} = 1:nx;
         end
      end
      casenums = cat(2,xdat{:,2});
      xdat = cat(2,xdat{:,1});
      ydat = cat(2,ydat{:});
   end
end

% Prep axes for this operation
units = get(gca,'defaulttextunits');
set(gca,'defaulttextunits','data');
bmf = get(gcf,'WindowButtonMotionFcn');
bdf = get(gcf,'WindowButtonDownFcn');
set(gcf,'WindowButtonMotionFcn','');
set(gcf,'WindowButtonDownFcn','');
xrange = diff(get(gca,'Xlim'));
yrange = diff(get(gca,'Ylim'));

% Get click location, then place label at the appropriate point
if (nargin<3), [x0,y0,x1,y1] = ginput0(1); end
h = [];
while(~isempty(x0))
   rectangular = (x0 ~= x1) && (y0 ~= y1); % is this a rubber band selection?

   % Get distance from each symbol to selection (box or point)
   xd = max(0, (x0-xdat)/xrange) + max(0, (xdat-x1)/xrange) + ~isfinite(xdat);
   yd = max(0, (y0-ydat)/yrange) + max(0, (ydat-y1)/yrange) + ~isfinite(ydat);
   d = xd.*xd + yd.*yd;
   [d1,idx] = min(d);
   if (rectangular)        % select all points in rectangle
      idx = find(d<=0);
   elseif d1>2*0.05^2
      idx = [];            % select nothing if too far away
   end
   
   if (length(idx) > 0)               % if any points were selected
      c0 = casenums(idx);             % get case numbers or labels
      if (c0 < 0)
         if iscell(cases)
            t0 = cases(-c0);
         else
            t0 = cases(-c0,:);
         end
      else
         t0 = strjust(int2str(c0(:)), 'left');
      end
      x0 = xdat(idx);                 % get coordinates
      y0 = ydat(idx);
      
      % Regular or ctrl/alt selection?
      adding = ~isequal(get(gcf,'SelectionType'),'alt');
      if adding
         % Regular selection, add label to selected points
         h0 = text(x0, y0, t0, 'VerticalAlignment', 'baseline', 'Tag','gname');
         h = [h; h0(:)];
         f = [];
         if (~rectangular), f = find(d <= 1e-5); end
         if (length(f) > 1)
            disp('Multiple observations appear at this point:');
            for j=1:length(f)
               cj = casenums(f(j));
               if (cj<0)
                  if iscell(cases)
                     txt = cases{-cj};
                  else
                     txt = cases(-cj,:);
                  end
                  disp(sprintf('   %s',txt));
               else
                  disp(sprintf('   %d',cj));
               end
            end
         end
      else
         % Remove label from selected points
         h0 = findobj(gca,'Type','text','Tag','gname');
         hrem = [];
         for k=1:length(x0)
            hrem = [hrem; findall(h0,'flat','Position',[x0(k) y0(k) 0])];
         end
         delete(hrem);
      end
   end
   if (nargin>2), break; end
   [x0,y0,x1,y1] = ginput0(1);
end

h = h(ishandle(h));
set(h,'units',units);
set(gca,'defaulttextunits',units);
set(gcf,'WindowButtonMotionFcn',bmf);
set(gcf,'WindowButtonDownFcn',bdf);

% ----- replacement for ginput/rbbox, gets correct axes
function [x0,y0,x1,y1] = ginput0(n)
[x,y,key] = ginput(1);
if (isempty(x) || isequal(key, 27))
   x0 = [];
   y0 = [];
   x1 = [];
   y1 = [];
   return;
end

a0 = gca;
a = findobj(gcf, 'Type', 'axes');
pt0 = get(a0, 'CurrentPoint');   % point at mouse down, current axes
pts0 = get(a, 'CurrentPoint');   % ditto, all axes
rbbox;
pt1 = get(a0, 'CurrentPoint');   % point at mouse up
pts1 = get(a, 'CurrentPoint');

% Make sure the current axes are set to the best choice
xlim = get(a0, 'XLim');
ylim = get(a0, 'YLim');
if (  x<xlim(1) || x>xlim(2) || y<ylim(1) || y>ylim(2) ...
    || strcmp(get(a0,'Visible'),'off'))
   % Point is outside current axes, look for better ones
   if (length(a) > 1)
      for j=1:length(a)
         aa = a(j);
         if strcmp(get(aa,'Visible'), 'on')
            xlim = get(aa, 'XLim');
            ylim = get(aa, 'YLim');
            cp = pts0{j};
            xx = cp(1,1);
            yy = cp(1,2);
            if (xx>=xlim(1) && xx<=xlim(2) && yy>=ylim(1) && yy<=ylim(2))
               % Update to these axes
               set(gcf, 'CurrentAxes', aa);
               a0 = aa;
               pt0 = cp;
               pt1 = pts1{j};
               break;
            end
         end
      end
   end
end

xlim = get(a0, 'XLim');
ylim = get(a0, 'YLim');
x0 = max(xlim(1), min(pt0(1,1), pt1(1,1)));
y0 = max(ylim(1), min(pt0(1,2), pt1(1,2)));
x1 = min(xlim(2), max(pt0(1,1), pt1(1,1)));
y1 = min(ylim(2), max(pt0(1,2), pt1(1,2)));

