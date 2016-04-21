function h = initdistfit(h,name,fitframe)
%INITDISTFIT Helper function to allow calls to m-file constructor

% $Revision: 1.1.8.6 $  $Date: 2004/03/09 16:17:02 $
% Copyright 2003-2004 The MathWorks, Inc.

% This is the meat of the constructor.  It is here, rather than in distfit.m, 
% because there is no way to have another method, specifically copyfit, call
% the m-file constructor.  Since it is a method of the distfit object, it only
% calls the builtin.  An example of this workaround in action is in copyfit.

% Initialize data members
h.support = 'unbounded';
h.numevalpoints = 100;
h.x = [];
h.y = [];
h.ftype = 'cdf';
h.conflev = 0.95;
h.exclusionrulename= '';
h.plot=0;
h.linehandle=[];
h.ColorMarkerLine = [];

% Create a default fit name if none was supplied
if nargin==1,
    taken = true;
    count=dfgetset('fitcount');
    if isempty(count)
        count = 1;
    end
    while taken
        name=sprintf('fit %i', count);
        if isempty(find(getfitdb,'name',name))
            taken = 0;
        else
            count=count+1;
        end
    end
    dfgetset('fitcount',count+1);    
end

h.name=name;
if nargin<3
   h.fitframe = [];
else
   h.fitframe=handle(fitframe);
end

list(6) = handle.listener(h,findprop(h,'name'),'PropertyPostSet',...
                          {@updatename,h});
list(5) = handle.listener(h,findprop(h,'conflev'),'PropertyPostSet',...
                          {@updateconflev,h});
list(4) = handle.listener(h,findprop(h,'showbounds'),'PropertyPostSet', {@changebounds,h});
list(3) = handle.listener(h,findprop(h,'plot'),'PropertyPostSet', ...
                          {@localupdate,h});
list(2) = handle.listener(h,'ObjectBeingDestroyed', {@cleanup,h});
list(1) = handle.listener(h,findprop(h,'dshandle'),'PropertyPostSet',...
                          {@updatelim,h});

h.listeners=list;

%=============================================================================
function updatename(hSrc,event,fit)

if fit.plot && ishandle(fit.linehandle)
   dfswitchyard('dfupdatelegend',fit.linehandle);
end

%=============================================================================
function updateconflev(hSrc,event,fit)

if ~isempty(fit.ybounds) && isequal(fit.fittype,'param')
   updateplot(fit);
end
%=============================================================================
function updatelim(hSrc,event,fit)

fit.xlim = xlim(fit);

%=============================================================================
function localupdate(hSrc,event,fit)

% Update plotted curve
updateplot(fit);

% Update plot limits
dfswitchyard('dfupdatexlim');
dfswitchyard('dfupdateylim');

% Update the java dialog to show current flag state
com.mathworks.toolbox.stats.FitsManager.getFitsManager.fitChanged(java(fit),...
        fit.name, fit.name);


%=============================================================================
function changebounds(hSrc,event,fit)

dist = fit.distspec;
if isempty(dist)
   hasbounds = false;
else
   hasbounds = dist.hasconfbounds;
end

if fit.showbounds && ~hasbounds
   % Undo requests for bounds if this distribution can't handle that
   fit.showbounds = hasbounds;
else
   % Otherwise the change is successful, so update the plot
   updateplot(fit);
end


%=============================================================================
function cleanup(hSrc,event,fit)

if ~isempty(fit.linehandle)
   if ishandle(fit.linehandle)
      list = fit.listeners;
      list(3).enable = 'off';
      fit.plot = 0;
      updateplot(fit);
      % Update plot limits
      dfswitchyard('dfupdatexlim');
      dfswitchyard('dfupdateylim');
   end
end

% Update list of probability plot distributions to remove this fit
dfswitchyard('dfupdateppdists');
