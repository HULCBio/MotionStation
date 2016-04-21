function h = dataset(x,y,weight,dsname,xvals,yvals,wvals,src)

% $Revision: 1.34.2.4 $  $Date: 2004/03/09 16:15:40 $
% Copyright 2001-2004 The MathWorks, Inc.

h = cftool.dataset;

% Define FactoryValues here, since R12fcs ignores them
h.xname='(none)';
h.yname='(none)';
h.weightname='(none)';
h.plot=1;
h.ColorMarkerLine = [];

NONE='(none)';
nargs = nargin;

% We may be asked to create an empty object not connected to the database
toconnect = 1;
if nargs==1 & isequal(x,'disconnected')
   toconnect = 0;
   h.plot=0;
   nargs = 0;
end

% For constructing empty object
if nargs==0
   x = 'x';
   y = 'y';
   weight = NONE;
   dsname = '';
   xvals = [];
   yvals = [];
   wvals = [];
   src = [];
   nargs = 8;
end

% if only x is given, swap x and y
if isequal(y,NONE)
   y=x;
   if nargin>=5
      yvals = xvals;
      nargs = max(6,nargs);
   end
   x=NONE;
end

if nargs>=6
   h.y = yvals;
else
   h.y=evalin('base',y);
end
if isempty(y), y = 'y'; end

if isequal(x,NONE)
   h.x=1:length(h.y);
elseif nargs>=5
   h.x = xvals;
else
   h.x=evalin('base',x);
end
if isempty(x), x = 'x'; end

if nargs<4 | isempty(dsname)
   if isequal(x,NONE)
      dsname=y;
   else
      dsname=sprintf('%s vs. %s',y,x);
   end
   if ~isequal(weight,NONE)
      dsname = sprintf('%s with %s',dsname,weight);
   end
end

%make sure default name is unique 
if ~isempty(find(getdsdb,'name',dsname))
   taken = 1; 
   i = 2; 
   % search for first unique name 
   while taken 
      tryname = sprintf('%s (%i)', dsname, i); 
      if isempty(find(getdsdb,'name',tryname))
         dsname = tryname;
         taken = 0; 
      else 
         i=i+1; 
      end 
   end 
end
h.name = dsname;

if isequal(weight, NONE)
	h.weight=[];
elseif nargs>=7
   h.weight = wvals;
else
	h.weight=evalin('base',weight);
end

if nargs>=8
   h.source = src;
else
   h.source=[];
end


% Make sure we store data as column vectors
h.x = h.x(:);
h.y = h.y(:);
h.weight = h.weight(:);
h.xlength = length(h.x);

% Now check for Inf or complex values in h.x, h.y and h.weight
xx=h.x;
yy=h.y;
ww=h.weight;
cplx = 0;
if ~isreal(xx) 
    xx = real(xx);
    cplx = 1;
end
if ~isreal(yy)
    yy = real(yy);
    cplx = 1;
end
if ~isreal(ww)
    ww = real(ww);
    cplx = 1;
end
infs = 0;
if any(isinf(xx))
    xx(isinf(xx)) = NaN;
    infs = 1;
end
if any(isinf(yy))
    yy(isinf(yy)) = NaN;
    infs = 1;
end
if any(isinf(ww))
    ww(isinf(ww)) = NaN;
    infs = 1;
end
h.x = xx;
h.y = yy;
h.weight=ww;

import com.mathworks.toolbox.curvefit.Analysis;
import com.mathworks.mwswing.MJOptionPane;

% using Analysis as parent to get the MATLAB icon. It is always initialized.
% This is required when starting cftool with data. 

if (infs & cplx)
  MJOptionPane.showMessageDialog(Analysis.getAnalysis, ...
  'Ignoring Infs in data and using only the real component of complex data.', ...
  'Import Data', MJOptionPane.INFORMATION_MESSAGE);
elseif infs
  MJOptionPane.showMessageDialog(Analysis.getAnalysis, ... 
  'Ignoring Infs in data.', ...
  'Import Data', MJOptionPane.INFORMATION_MESSAGE);
elseif cplx
  MJOptionPane.showMessageDialog(Analysis.getAnalysis, ...
  'Using only the real component of complex data.', ...
  'Import Data', MJOptionPane.INFORMATION_MESSAGE);
end

% Remember the names
h.xname = x;
h.yname = y;
h.weightname = weight;

updatelim(h);
% add listeners
list(1) = handle.listener(h,findprop(h,'plot'),'PropertyPostSet', {@update,h});
list(2) = handle.listener(h,'ObjectBeingDestroyed', {@cleanup,h});
list(3) = handle.listener(h,findprop(h,'name'),'PropertyPostSet', {@newname,h});
h.listeners=list;

% add it to the list of datasets
if toconnect
   connect(h,getdsdb,'up');
end

if h.plot==1 && nargin>0
    updatelim(h);
    cfswitchyard('cfmplot',[],[],h);
end

% ---- listener updates limits and calls plotting function
function update(hSrc,event,ds)

updatelim(ds);
dsmgr = com.mathworks.toolbox.curvefit.DataSetsManager.getDataSetsManager;
dsmgr.dataSetListenerTrigger(java(ds), dsmgr.DATA_SET_CHANGED, '', '');
cfswitchyard('cfmplot',hSrc,event,ds);


% ---- listener updates name in legend
function newname(hSrc,event,ds)

cfswitchyard('cfupdatelegend',cfgetset('cffig'));


% ---- Remember x and y limits, useful for selecting plot limits
function updatelim(h);

if isempty(h.x)
   h.xlim = [];
else
   h.xlim = [min(h.x) max(h.x)];
end
if isempty(h.y)
   h.ylim = [];
else
   h.ylim = [min(h.y) max(h.y)];
end

% ---- listener to unplot dataset when the object is destroyed
function cleanup(hSrc,event,dataset)

changed = 0;
if ~isempty(dataset.line)
   if ishandle(dataset.line)
      list = dataset.listeners;
      list(1).enable = 'off';
      dataset.plot = 0;
      changed = 1;
      cfswitchyard('cfmplot',hSrc,event,dataset);
   end
end
if changed
   cfswitchyard('cfupdatelegend',cfgetset('cffig'));
end
