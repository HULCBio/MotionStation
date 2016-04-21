function hh = pie3(varargin)
%PIE3   3-D pie chart.
%   PIE3(X) draws a 3-D pie plot of the data in the vector X.  The values
%   in X are normalized via X/SUM(X) to determine the area of each slice of
%   pie.  If SUM(X) <= 1.0, the values in X directly specify the area of
%   the pie slices.  Only a partial pie will be drawn if SUM(X) < 1.
%
%   PIE3(X,EXPLODE) is used to specify slices that should be  pulled out
%   from the pie.  The vector EXPLODE must be the same size  as X.  The
%   slices where EXPLODE is non-zero will be pulled out.
%
%   PIE3(...,LABELS) is used to label each pie slice with cell array
%   LABELS.  LABELS must be the same size as X and can only contain
%   strings.
%
%   PIE3(AX,...) plots into AX instead of GCA.
%
%   H = PIE3(...) returns a vector containing patch, surface, and text
%   handles. 
%
%   Example
%      pie3([2 4 3 5],[0 1 1 0],{'North','South','East','West'})
%
%   See also PIE.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.5 $  $Date: 2004/04/10 23:32:00 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

txtlabels={};

if nargs==0, error('Not enough input arguments.'); end

x = args{1}(:); % Make sure it is a vector
args = args(2:end);

nonpositive = (x <= 0);
if any(nonpositive)
  warning('MATLAB:pie:NonPositiveData',...
          'Ignoring non-positive data in pie chart.');
  x(nonpositive) = [];
end

if nargs==1, explode = zeros(size(x));
elseif nargs==2 & isnumeric(args{1}),
   explode = args{1};
   explode = explode(:); % Make sure it is a vector
   if any(nonpositive)
     explode(nonpositive) = [];
   end
elseif nargs==2 & iscell(args{1}),
   explode = zeros(size(x));
   txtlabels = args{1};
   if any(nonpositive)
     txtlabels(nonpositive) = [];
   end
elseif nargs==3 & iscell(args{2}),
   explode = args{1};
   explode = explode(:); % Make sure it is a vector
   if any(nonpositive)
     explode(nonpositive) = [];
   end
   txtlabels = args{2};
   if any(nonpositive)
     txtlabels(nonpositive) = [];
   end
else error('Too many arguments or invalid string cell array.'); end

if sum(x) > 1+sqrt(eps), x = x/sum(x); end

if length(txtlabels)~=0 & length(x)~=length(txtlabels),
  error('Cell array of strings must be the same length as X.');
end
if length(x) ~= length(explode),
  error('X and EXPLODE must be the same length.');
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

theta0 = pi/2;
maxpts = 100;
zht = .35;

h = [];
for i=1:length(x)
  n = max(1,ceil(maxpts*x(i)));
  r = [0;ones(n+1,1);0];
  theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
  [xtext,ytext] = pol2cart(theta0 + x(i)*pi,1.25);
  [xx,yy] = pol2cart(theta,r);
  if explode(i),
    [xexplode,yexplode] = pol2cart(theta0 + x(i)*pi,.1);
    xtext = xtext + xexplode;
    ytext = ytext + yexplode;
    xx = xx + xexplode;
    yy = yy + yexplode;
  end
  theta0 = max(theta);
  if x(i)<.01,
    lab = '< 1';
  else
    lab = int2str(round(x(i)*100));
  end
  z = zht(ones(size(xx)));
  h = [h,patch('XData',xx,'YData',yy,'Zdata',zeros(size(xx)),...
               'CData',i*ones(size(xx)),'FaceColor','Flat','parent',cax), ...
         surface([xx,xx],[yy,yy],[zeros(size(xx)),z], ...
                i*ones(size(xx,1),2),'parent',cax), ...
         patch('XData',xx,'YData',yy,'Zdata',z, ...
                'CData',i*ones(size(xx)),'FaceColor','Flat','parent',cax)];
  if length(txtlabels)~=0,
     h = [h,text(xtext,ytext,zht,txtlabels{i}, ...
             'HorizontalAlignment','center','parent',cax)];
  else
     h = [h,text(xtext,ytext,zht,[lab,'%'], ...
             'HorizontalAlignment','center','parent',cax)];
  end
end

if ~hold_state, 
  set(cax,'NextPlot',next); 
  axis(cax,'off','image',[-1.2 1.2 -1.2 1.2])
  view(cax,3)
end

if nargout>0, hh = h; end

% Register handles with m-code generator
if ~isempty(h)
   mcoderegister('Handles',h,'Target',h(1),'Name','pie3');
end
