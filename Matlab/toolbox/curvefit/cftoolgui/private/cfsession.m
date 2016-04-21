function ok=cfsession(action,fn)
%CFSESSION Clear, load, or save a Curve Fitting session

%   $Revision: 1.15.2.3 $  $Date: 2004/03/09 16:15:43 $
%   Copyright 2001-2004 The MathWorks, Inc.

% Wrap real function with a try/catch block so we can control the legend
oldleg = cfgetset('showlegend');
if isequal(oldleg,'on'), cfgetset('showlegend','off'); end

try
   if nargin<2
      ok = cfsession1(action);
   else
      ok = cfsession1(action,fn);
   end
catch
   uiwait(errordlg(sprintf('Unexpected error occurred: %s', lasterr),...
                   'Curve Fitting Tool','modal'))
end
if isequal(oldleg,'on')
   cfgetset('showlegend','on');
   cfupdatelegend(cfgetset('cffig'));
end


% --------- Helper function does the real work
function ok=cfsession1(action,fn)

import com.mathworks.toolbox.curvefit.*;

ok = 1;
ftypenow = 'Curve Fitting session';
versionnow = 1;     % the most current version
allversions = [1];  % a list of all supported versions
lineproperties = {'Color' 'LineStyle' 'LineWidth' 'Marker' 'MarkerSize'};

% Variables we save, and the number required to be in a saved file
varnames = {'ftype' 'version' 'allds' 'dsinfo' 'allfits' 'allcfits' ...
            'fitinfo' 'customlibrary' 'outliers'};
nrequired = 8;

switch(action)
 % ---- Save current Curve Fitting tool session
 case 'save'
   ftype = ftypenow;
   version = versionnow;
  
   % Get all M data set object instances and some properties
   allds = cfgetalldatasets;
   nds = length(allds);
   dsinfo = cell(nds,1);
   for j=1:length(allds)
      % Save all datasets and their plot info
      dj = allds{j};
      dsinfo{j} = dj.plot;
   end
   
   % Get all M fit object instances and some properties
   allfits = cfgetallfits;
   nfits = length(allfits);
   allcfits = cell(size(allfits));
   fitinfo = cell(size(allfits));
   for j=1:nfits
      % Save cfit objects separately, remember line properties
      fj = allfits{j};
      fitinfo{j} = fj.plot;
      allcfits{j} = fj.fit;
   end
   
   % get the user-defined custom equations
   customlibrary=cfgetset('customLibrary');
   
   % Get the outliers (excluded sets)
   outdb = getoutlierdb;
   outliers = find(outdb);
   outliers(outliers==outdb) = [];

   % Get file name to use, remember the directory name
   olddir = cfgetset('dirname');
   filespec = [olddir '*.cfit'];
   if nargin<2 | isempty(fn)
      [fn,pn] = uiputfile(filespec,'Save Session');
      if isequal(fn,0) | isequal(pn,0)
         ok = 0;
         return
      end
      if ~ismember('.',fn)
         fn = [fn '.cfit'];
      end
      cfgetset('dirname',pn);
      fn = [pn fn];
   end

   % Select a file and save the session variables
   le = lasterr;
   lasterr('');
   try
      save(fn, varnames{:}, '-mat');
   catch
      uiwait(errordlg(sprintf('Error saving session file: %s', lasterr),...
                      'Save Error','modal'))
      ok = 0;
      return
   end
   lasterr(le);
   ok = 1;
   
 % ---- Load new session into Curve Fitting tool
 case 'load'
   % Get file name and load from it, remember the directory name
   olddir = cfgetset('dirname');
   filespec = [olddir '*.cfit'];
   
   if nargin<2 | isempty(fn)
      [fn,pn] = uigetfile(filespec,'Load Session');
      if isequal(fn,0) | isequal(pn,0)
         return
      end
      if ~ismember('.',fn)
         fn = [fn '.cfit'];
      end
      cfgetset('dirname',pn);
      fn = [pn fn];
   end
   
   % Clear current session
   cfsession('clear');
   com.mathworks.toolbox.curvefit.DataSetsManager.getDataSetsManager.turnOffUDDListener;
   try
      s = load('-mat',fn);
   catch
      uiwait(errordlg(sprintf('Error loading session file: %s', lasterr),...
                      'Load Error','modal'))
   	  com.mathworks.toolbox.curvefit.DataSetsManager.getDataSetsManager.turnOnUDDListener;
      return
   end
   com.mathworks.toolbox.curvefit.DataSetsManager.getDataSetsManager.turnOnUDDListener;
   
   for j=1:nrequired
      if ~isfield(s,varnames{j})
         uiwait(errordlg('Not a valid Curve Fitting session file',...
                      'File Invalid','modal'))
         return
      end
   end
   if ~isequal(s.ftype,ftypenow)
      uiwait(errordlg('Not a valid Curve Fitting session file',...
                      'File Invalid','modal'))
      return
   end

   if ~ismember(s.version,allversions)
      uiwait(errordlg('Bad version number in Curve Fitting session file',...
                      'Invalid Version','modal'))
      return
   end

   % Plot datasets that are flagged for plotting
   for j=1:length(s.allds);
      dj = s.allds{j};
      dj.line = [];
      updatelim(dj);
      if s.dsinfo{j}
         if dj.plot
            % if plot flag already set, need to trigger listener directly
            cfmplot([],[],dj);
         else
            % otherwise setting the flag will trigger the listener
            dj.plot = 1;
         end
      else
         dj.plot = 0;
      end
      issmooth = java.lang.Boolean(~isempty(dj.Source));
      dslength = java.lang.Double(dj.xlength);
      com.mathworks.toolbox.curvefit.DataSetsManager.getDataSetsManager.addDataSet(...
            java(dj),dj.name,dslength,issmooth);
   end
   
   % Fix up fit objects
   for j=1:length(s.allfits)
      fj = s.allfits{j};

      % Restore all cfit object instances
      fj.fit = s.allcfits{j};
   
      % Restore all dataset handles
      dsname = fj.dataset;
      for k=1:length(s.allds)
         if isequal(dsname,s.allds{k}.name)
            fj.dshandle = s.allds{k};
            break;
         end
      end

      % Plot if so flagged
      if s.fitinfo{j}
         fj.line = [];
         fj.rline = [];
         fj.plot = 1;
      end
      isgood = java.lang.Boolean(fj.isgood);
      com.mathworks.toolbox.curvefit.FitsManager.getFitsManager.addFit(...
            java(fj),fj.name,isgood,fj.outlier,dsname);
   end
   
   % Restore the user-defined custom equations
   cfgetset('customlibrary',s.customlibrary);
   if ~isempty(s.customlibrary)
      names=s.customlibrary.names;
      customEquationList=CustomEquationList.getInstance;
      for i=1:length(names)
         customEquationList.addEquation(names{i});
      end
   end
   
 % ---- Clear current Curve Fitting tool session
 case 'clear'
   % Trigger java listeners to clear all saved java content
   CFToolClearManager.getCFToolClearManager.listenerTrigger;

   % Delete all udd fit object instances
   allfits = cfgetallfits;
   for j=1:length(allfits)
      fj = allfits{j};
      delete(fj);
   end
   
   % Delete all udd data set object instances
   allds = cfgetalldatasets;
   for j=1:length(allds)
      dj = allds{j};
      if dj.plot, dj.plot = 0; end
      delete(dj);
   end

   % Delete all udd outlier object instances
   outdb = getoutlierdb;
   outliers = find(outdb);
   outliers(outliers==outdb) = [];
   delete(outliers);

	%init (behind the scenes) analysis and plot
	com.mathworks.toolbox.curvefit.Analysis.initAnalysis;
	com.mathworks.toolbox.curvefit.Plotting.initPlotting;
end

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

