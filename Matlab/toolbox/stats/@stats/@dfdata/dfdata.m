function h = dfdata(yname,cname,fname,dsname,ydata,cdata,fdata)
%DFDATA Constructor for stats.dfdata class

% $Revision: 1.1.6.8 $    $Date: 2004/03/09 16:17:01 $
% Copyright 2003-2004 The MathWorks, Inc.

h = stats.dfdata;
nargs = nargin;

NONE='(none)';

% We may be asked to create an empty object not connected to the database
if nargs==1 & isequal(y,'disconnected')
   toconnect = 0;
   nargs = 0;
else
   toconnect = 1;
end

% For constructing empty object
if nargs==0
   yname = 'y';
   cname = '';
   fname = '';
   dsname = '';
   ydata = [1];
   cdata = [];
   fdata = [];
   nargs = 7;
end


% Fill in fields using arguments supplied
if isempty(yname)
   yname = 'y';
   h.yexp = '';
else
   h.yexp = yname;
end
h.yname = yname;

if isequal(cname,NONE)
   h.censexp = '';
else
   h.censexp = cname;
end
h.censname = cname;

if isequal(fname,NONE)
   h.freqexp = '';
else
   h.freqexp = fname;
end
h.freqname = fname;

h.y = ydata(:);
h.ylength = length(ydata);
h.datalo = min(ydata);
h.datahi = max(ydata);

h.censored = cdata(:);

if isempty(cdata)
   isint = all(isnan(ydata) | (ydata == round(ydata)));
else
   t = ydata(~cdata);
   isint = all(t == round(t));
end
h.isinteger = isint;
h.iscensored = ~all(cdata(:) == 0);

h.frequency = fdata(:);


% Now go back and process the data set name argument
if nargs<4 || isempty(dsname)
   dsname = sprintf('%s data',yname);
end
dsdb = dfswitchyard('getdsdb');
taken = 1;
basename = dsname;
i = 1;
while taken
   taken = 0;
   ds = down(dsdb);
   while(~isempty(ds))
      if isequal(ds.name,dsname)
         taken = 1;
         break
      end
      ds = right(ds);
   end
   if taken
      i = i+1;
      dsname = sprintf('%s (%d)',basename,i);
   end
end

h.name = dsname;
h.conflev = 0.95;
h.plotok = 0;      % false, it may not be ok to plot this on the current figure
h.plot = 0;        % false, by default we are not going to plot this
yincl = getincludeddata(h,[]);
h.datalim = [min(yincl), max(yincl)];
setftype(h,'cdf');

% Set up default bin width information

binDlgInfo = dfgetset('binDlgInfo');
h.binDlgInfo = binDlgInfo;

% add listeners
list(1) = handle.listener(h,findprop(h,'plot'),'PropertyPostSet', {@localupdate,h});
list(2) = handle.listener(h,'ObjectBeingDestroyed', {@cleanup,h});
list(3) = handle.listener(h,findprop(h,'name'),'PropertyPostSet', {@newname,h});
list(4) = handle.listener(h,findprop(h,'showbounds'),'PropertyPostSet', {@localupdate,h});
list(5) = handle.listener(h,findprop(h,'conflev'),'PropertyPostSet',...
                          {@updateconflev,h});
h.listeners = list;

if toconnect
   % Add to data set array
   connect(h,dsdb,'up');
end


%=============================================================================
function newname(hSrc,event,ds)

if ds.plot && ishandle(ds.line)
   dfswitchyard('dfupdatelegend',ds.line);
end


% ---- listener updates confidence bounds for new confidence level
function updateconflev(hSrc,event,ds)

if ~isempty(ds.cdflower) || ~isempty(ds.cdfupper) || ~isempty(ds.plotbnds)
   % Clear out data needing to be recomputed
   ds.cdfLower = [];
   ds.cdfUpper = [];
   ds.plotbnds = [];

   % If the bounds are plotted, update them
   if ~isempty(ds.boundline) && ishandle(ds.boundline)
      delete(ds.boundline);
      updateplot(ds);
   end
end

% ---- listener to unplot dataset when the object is destroyed
function cleanup(hSrc,event,ds)

if ~isempty(ds.line) && ishandle(ds.line)
    list = ds.listeners;
    list(1).enable = 'off';
    ds.plot = 0;
    updateplot(ds);
    % Update plot limits
    dfswitchyard('dfupdatexlim');
    dfswitchyard('dfupdateylim');
end

% ---- listener updates limits and calls plotting function
function localupdate(hSrc,event,ds)

% Plot if possible, force flag off if not
if dfswitchyard('dfcanplotdata',ds)
   ds.plotok = 1;
   updateplot(ds);

   % Update plot limits
   dfswitchyard('dfupdatexlim');
   dfswitchyard('dfupdateylim');
else
   ds.plot = 0;
   ds.plotok = 0;
end

% Update the java dialog to show current flag state
com.mathworks.toolbox.stats.DataSetsManager.getDataSetsManager.dataSetChanged(java(ds),'','');

