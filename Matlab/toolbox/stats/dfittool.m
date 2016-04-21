function varargout=dfittool(varargin)
%DFITTOOL Distribution Fitting Tool.
%   DFITTOOL displays a window for fitting distributions to data.  You can
%   create a data set by importing data from your workspace, and you can
%   fit distributions and display them over plots of the empirical distribution
%   of the data.

%   DFITTOOL(Y,CENS,FREQ,DSNAME) creates a data set named DSNAME using the data
%   vector Y, censoring indicator CENS, and frequency vector FREQ.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2004/02/01 22:10:18 $

import com.mathworks.toolbox.stats.*;

% Handle call-back
if (nargin > 0 && ischar(varargin{1}))
    out = switchyard(varargin{:});
    if nargout>0
       varargout = {out};
    end
    return
end

% Can't proceed unless we have desktop java support
if ~usejava('swing')
    error('stats:dfittool:JavaSwingRequired',  ...
          'Cannot use dfittool unless you have Java and Swing available.');
end

% Get a reference to the singleton instance of the java
% distribution fitting class
DistributionFitting.showDistributionFitting;
dft = DistributionFitting.getDistributionFitting;

% make sure there are instances of datasets and fits and outliers
DataSetsManager.getDataSetsManager;
FitsManager.getFitsManager;
OutliersManager.getOutliersManager;

% Send the gui information about the distributions we can fit
dfgetset('alldistributions','');  % clear definitions left-over from before
[dists,errid] = dfgetdistributions;
if ~isempty(errid)
   errordlg(sprintf('Error trying to import custom distributions:\n%s',...
                    errid),...
            'Distribution Fitting Tool','modal');
end
dfsetdistributions(dft,dists);

dfgetset('dft',dft);

% Try to get old figure
dffig = dfgetset('dffig');

% If the handle is empty, create the object and save the handle
if (isempty(dffig) || ~ishandle(dffig))
   dffig = dfcreateplot;
   dfsession('clear');
   dfsetfunction(dffig,'pdf');
else
   dfsession('clear');
   figure(dffig);
end

% Initialize default bin width rules information
initdefaultbinwidthrules;
 
% Start with input data, or put up message about importing data
ds = [];
if nargin>0
   % If data were passed in, set up argument list for that case
   dsargs = {[] [] [] ''};
   n = min(4,nargin);
   dsargs(1:n) = varargin(1:n);
   for j=1:min(3,n)
      dsargs{4+j} = inputname(j);   % get data names if possible
   end
   [ds,err] = dfcreatedataset(dsargs{:});
   
   if ~isempty(err)
      err = sprintf('Error importing data:\n%s',err);
      errordlg(err,'Bad Input Data','modal');
   end
end

if nargin==0 || isempty(ds)
   % init
   text(.5,.5,xlate('Select "Data" to begin distribution fitting'),...
        'Parent',get(dffig,'CurrentAxes'),'Tag','dfstarthint',...
        'HorizontalAlignment','center');
end

if nargout==1
   varargout={dft};
end


% --------------------------------------------
function out = switchyard(action,varargin);
%SWITCHYARD Dispatch menu call-backs and other actions to private functions

cbo = gcbo;
if ~isempty(cbo) && ~isa(cbo,'schema.prop')
   dffig = gcbf;
else
   dffig = [];
end
if isempty(dffig)
   dffig = dfgetset('dffig');
end
out = [];

switch(action)
    % Fitting actions
    case 'addsmoothfit'
         fit = dfaddsmoothfit(varargin{:});
         if ~isempty(fit)
             fit.fitframe.setTitle('Edit Fit');
         end
         dfupdatelegend(dffig);
         dfupdateylim;
         if ~isempty(fit)
            out = java(fit);
         end
         dfupdateppdists(dffig);
    case 'addparamfit'
         fit = dfaddparamfit(varargin{:});
         if ~isempty(fit)
             fit.fitframe.setTitle('Edit Fit');
         end
         dfupdatelegend(dffig);
         dfupdateylim;
         if ~isempty(fit)
            out = java(fit);
         end
         dfupdateppdists(dffig);
    % Various graph manipulation actions
    case 'adjustlayout'
         dfadjustlayout(dffig);
         dfgetset('oldposition',get(dffig,'Position'));
         dfgetset('oldunits',get(dffig,'Units'));
    case 'defaultaxes'
         dfupdatexlim;
         dfupdateylim;

    % Actions to toggle settings on or off
    case 'togglegrid'
         dftogglegrid(dffig);
    case 'togglelegend'
         dftogglelegend(dffig);
    case 'toggleaxlimctrl'
         dftoggleaxlimctrl(dffig)

    % Actions to set certain parameters
    case 'setconflev'
         dfsetconflev(dffig,varargin{:});

    % Actions related to the session
    case 'clear session'
         delete(findall(gcbf,'Tag','dfstarthint'));
         if dfasksavesession(dffig);
            dfsession('clear');
         end
    case 'save session'
         dfsession('save');
    case 'load session'
         delete(findall(gcbf,'Tag','dfstarthint'));
         if dfasksavesession(dffig);
            dfsession('load');
         end

    % Assorted other menu actions
    case 'generate code'
         dffig2m;
    case 'clear plot'
         delete(findall(dffig,'Tag','dfstarthint'));
         dfcbkclear;
    case 'import data'
         delete(findall(dffig,'Tag','dfstarthint'));
         com.mathworks.toolbox.stats.Data.showData;
    case 'duplicate'
         dfdupfigure(gcbf);
    case 'gettipfcn'
         out = @dftips;
end

% --------------------------------------------
function initdefaultbinwidthrules()
binDlgInfo = struct('rule', 1, 'nbinsExpr', '', 'nbins', [], 'widthExpr', '', ...
                    'width', [], 'placementRule', 1, 'anchorExpr', '', ...
                    'anchor', [], 'applyToAll', false, 'setDefault', false);
dfgetset('binDlgInfo', binDlgInfo);


