function cffig2m(cffig,mfilename)
%CFFIG2M Turn figure into an M file that can produce the figure

%   $Revision: 1.17.2.7 $  $Date: 2004/02/01 21:39:47 $
%   Copyright 2001-2004 The MathWorks, Inc.

dsdb = getdsdb;
fitdb = getfitdb;
if isempty(down(dsdb)) && isempty(down(fitdb))
   emsg = 'Cannot generate M-file when no datasets or fits exist.';
   errordlg(emsg,'Error Generating M-file','modal');
   return
end

if nargin<1, cffig = cfgetset('cffig'); end

if nargin<2
   % Get file name to use, remember the directory name
   olddir = cfgetset('dirname');
   filespec = [olddir '*.m'];
   [mfilename,pn] = uiputfile(filespec,'Generate M-file');
   if isequal(mfilename,0) || isequal(pn,0)
      return
   end
   if ~ismember('.',mfilename)
      mfilename = [mfilename '.m'];
   end
   cfgetset('dirname',pn);
   mfilename = sprintf('%s%s',pn,mfilename);
end

% Get M file name with .m suffix, and get corresponding function name
if length(mfilename)<2 || ~isequal(mfilename(end-1:end),'.m')
   mfilename = sprintf('%s.m',mfilename);
end
fcnname = mfilename(1:end-2);
k = max(find(fcnname(1:end-1)=='\'));
if ~isempty(k)
   fcnname = fcnname(k+1:end);
end
k = max(find(fcnname(1:end-1)=='/'));
if ~isempty(k)
   fcnname = fcnname(k+1:end);
end
   
% Set up some variables for later
allprop = {'Color' 'Marker' 'LineStyle' 'LineWidth' 'MarkerSize'};
dslist = cell(0,5);
showlegend = isequal(cfgetset('showlegend'),'on');
haveresiduals = 0;

% Create arrays to receive code text
blkc = cell(0,1);    % block of comment lines
blks = cell(0,1);    % block of setup lines
blkd = cell(0,1);    % block of data-related lines
blkf = cell(0,1);    % block of fit-related lines
blke = cell(0,1);    % block of lines at end

% Write introduction to dataset section, including figure
% preparation code
blks{end+1} = '% Set up figure to receive datasets and fits';
blks{end+1} = 'f_ = clf;';
blks{end+1} = 'figure(f_);';
if showlegend
   blks{end+1} = 'legh_ = []; legt_ = {};   % handles and text for legend';
end
blks{end+1} = 'xlim_ = [Inf -Inf];       % limits of x axis';

% Process each dataset
nds = 0;
ds = down(dsdb);
arglist = {};
nonenames = 0;
while ~isempty(ds)
   nds = nds + 1;
   dsname = ds.name;
   dssrc = ds.source;
   
   % Was this dataset created from raw data or from another source?
   smoothed = ~isempty(dssrc);
   if smoothed
      xname = dssrc{1,1};
      oldyname = dssrc{1,2};
      yname = sprintf('sm_.y%d',nds);
      wname = '';
   else
      xname = ds.xname;
      yname = ds.yname;
      wname = ds.weightname;
      oldyname = yname;
   end
   wtd = ~isempty(ds.weight) & ~isempty(wname);
   if isequal(lower(xname),'(none)')
      xname = '';
   end

   % Each variable name becomes a function argument
   if ~isempty(xname) && isempty(strmatch(xname,arglist,'exact'))
      arglist{end+1} = xname;
      newx = 1;
   else
      newx = 0;
   end
   if isempty(strmatch(yname,arglist,'exact')) && ~smoothed
      arglist{end+1} = yname;
      newy = 1;
   else
      newy = 0;
   end
   if wtd && isempty(strmatch(wname,arglist,'exact'))
      arglist{end+1} = wname;
      neww = 1;
   else
      neww = 0;
   end
   
   % Create comment text associating dataset with variable names
   blkc{end+1} =  ' ';
   blkc{end+1} =  sprintf('%% Data from dataset "%s":',dsname);
   if ~isempty(xname)
      blkc{end+1} =  sprintf('%%    X = %s:',xname);
   end
   blkc{end+1} =  sprintf('%%    Y = %s:',oldyname);
   if wtd
      blkc{end+1} =  sprintf('%%    Weights = %s:',wname);
   else
      blkc{end+1} =  '%    Unweighted';
   end
   
   % Create code to plot this dataset into the figure we have created
   blkd{end+1} = ' ';
   blkd{end+1} = sprintf('%% --- Plot data originally in dataset "%s"',dsname);
   if isempty(xname)
      nonenames = nonenames + 1;
      xname = sprintf('x_%d',nonenames);
      blkd{end+1} = sprintf('%s = (1:numel(%s))'';',xname,yname);
   elseif newx
      blkd{end+1} = sprintf('%s = %s(:);',xname,xname);
   end
      
   if newy, blkd{end+1} = sprintf('%s = %s(:);',yname,yname); end
   if neww, blkd{end+1} = sprintf('%s = %s(:);',wname,wname); end
   if smoothed
      % May need to reconstruct smoothed data from new input data
      for j=1:size(dssrc,1)
         span = dssrc{j,3};
         method = dssrc{j,4};
         degree = dssrc{j,5};
         blkd{end+1} = sprintf('%s = smooth(%s,%s,%g,''%s'',%g);',...
                               yname,xname,oldyname,span,method,degree);
         oldyname = yname;
      end
   end
   dsline = ds.line;
   if ~isempty(dsline) && ishandle(dsline)
      propvals = get(dsline,allprop);
      [c,m,l,w,s] = deal(propvals{:});
      blkd{end+1} =  sprintf(...
          'h_ = line(%s,%s,''Parent'',ax_,''Color'',[%g %g %g],...', ...
               xname,yname,c(1),c(2),c(3));
      blkd{end+1} =  sprintf(...
          '     ''LineStyle'',''%s'', ''LineWidth'',%d,...', ...
               l,w);
      blkd{end+1} =  sprintf(...
          '     ''Marker'',''%s'', ''MarkerSize'',%d);', ...
               m,s);
      blkd{end+1} =  sprintf('xlim_(1) = min(xlim_(1),min(%s));',xname);
      blkd{end+1} =  sprintf('xlim_(2) = max(xlim_(2),max(%s));',xname);

      if showlegend
         blkd{end+1} = 'legh_(end+1) = h_;';
         blkd{end+1} = sprintf('legt_{end+1} = ''%s'';',quotedtext(dsname));
      end
   else
      blkd{end+1} =  '% This dataset does not appear on the plot';
      blkd{end+1} =  '% Add it to the plot by removing the if/end statements that follow';
      blkd{end+1} =  '% and by selecting the desired color and marker';
      blkd{end+1} =  'if 0';
      propvals = '''Color'',''r'',''Marker'',''.'',''LineStyle'',''none''';      
      blkd{end+1} =  sprintf('   h_ = line(%s,%s,%s);', xname,yname,propvals);
      blkd{end+1} =  sprintf('   xlim_(1) = min(xlim_(1),min(%s));',xname);
      blkd{end+1} =  sprintf('   xlim_(2) = max(xlim_(2),max(%s));',xname);

      if showlegend
         blkd{end+1} = '   legh_(end+1) = h_;';
         blkd{end+1} = sprintf('   legt_{end+1} = ''%s'';',quotedtext(dsname));
      end
      blkd{end+1} =  'end       % end of "if 0"';
   end

   % Remember stuff about this dataset
   dslist{nds,1} = dsname;
   dslist{nds,2} = xname;
   dslist{nds,3} = yname;
   if wtd, dslist{nds,4} = wname; end
   if ~isempty(dssrc), dslist{nds,5} = dssrc; end
   
   % Move to next dataset
   ds = right(ds);
end

% Process each fit
nfit = 0;
ft = down(fitdb);
while ~isempty(ft)
   nfit = nfit + 1;
   ok = 1;
   if ~ft.isgood
      ok = 0;
   end
   if ok
      dsname = ft.dataset;
      fitname = ft.name;
      dsnum = strmatch(dsname,dslist(:,1),'exact');
      if isempty(dsnum)
         ok = 0;
      end
   end
   
% altering indentation to avoid massive changes
if ok
   xname = dslist{dsnum,2};
   yname = dslist{dsnum,3};
   wname = dslist{dsnum,4};
   wtd = ~isempty(wname);

   cf = ft.fit;
   ftype = type(cf);
   modeldef = ftype;
   
   % Create code to re-create this fit
   blkf{end+1} =  sprintf('\n%% --- Create fit "%s"',fitname);
   fitargs = '';        % extra arguments for fit

   % If an excluded set exists in this fit, create an exclusion vector
   excluding = 0;
   if ~isequal(ft.outlier,'(none)')
      outset = find(getoutlierdb,'name',ft.outlier);
      blkf{end+1} = sprintf('\n%% Apply exclusion rule "%s"',ft.outlier);

      % First deal with the exclusion vector
      evec = outset.exclude;
      n = length(evec);
      if n>0
         excluding = 1;
         blkf{end+1} = sprintf('if length(%s)~=%d',xname,n);
         blkf{end+1} = sprintf(...
             '   error(''Exclusion rule "%s" is incompatible with %s'');',...
             ft.outlier,xname);
         blkf{end+1} = 'end';
         majority = (sum(evec) > .5*n);
         if majority
            blkf{end+1} = sprintf('ex_ = logical(ones(length(%s),1));',xname);
         else
            blkf{end+1} = sprintf('ex_ = logical(zeros(length(%s),1));',xname);
         end
         if n>0
            rowspec = makerowspec(evec == ~majority);
            blkf{end+1} = sprintf('ex_([%s]) = %d;',rowspec,~majority);
         end
      end
      
      % Apply restrictions based on X and Y
      if outset.restrictDomain
         comptxt1 = makecomptxt(xname,...
                          outset.domainLow,outset.domainLowLessEqual,...
                          outset.domainHigh,outset.domainHighLessEqual);
      else
         comptxt1 = '';
      end
      if outset.restrictRange
         comptxt2 = makecomptxt(yname,...
                          outset.rangeLow,outset.rangeLowLessEqual,...
                          outset.rangeHigh,outset.rangeHighLessEqual);
      else
         comptxt2 = '';
      end
      if isempty(comptxt1)
         comptxt1 = comptxt2;
      elseif ~isempty(comptxt2)
         comptxt1 = sprintf('%s | %s',comptxt1,comptxt2);
      end
      
      % Create a combined exclusion vector if necessary
      if ~isempty(comptxt1)
         excluding = 1;
         if n>0
            blkf{end+1} = sprintf('ex_ = ex_ | %s;',comptxt1);
         else
            blkf{end+1} = sprintf('ex_ = %s;',comptxt1);
         end
      end
   end
   
   % For custom models, get lots of information about the function
   ftypeargs = '';      % extra arguments for fittype
   start = [];          % starting points for iteration
   havefitopt = 0;
   if isempty(strmatch('custom',ftype))
      modeldef = sprintf('''%s''',modeldef);
   else
      % Get either the array of terms or the function expression
      if islinear(cf)
         modeldef = cell2text(linearterms(cf));
      else
         modeldef = cell2text(formula(cf));
      end
      
      % Get the variable and coefficient names
      cnames = coeffnames(cf);
      ftypeargs = sprintf(...
          ',...\n     ''dependent'',%s,''independent'',%s',...
          cell2text(dependnames(cf)), cell2text(indepnames(cf)));
      ftypeargs = sprintf('%s,...\n     ''coefficients'',%s',ftypeargs,...
                          cell2text(cnames));

      % Get the problem parameter names, but this is not supported
      % in release one so it should be tested if they're added later
      pnames = probnames(cf);
      if length(pnames)>0
         ftypeargs = sprintf('%s,...\n     ''problem'',%s',ftypeargs,...
                             cell2text(pnames));
         pvals = num2cell(probvalues(cf));
         fitargs = sprintf('%s,''prob'',%s',fitargs,cell2text(pvals));
      end
   end

   % Get the fitoptions for this fit
   try
      oldopts = fitoptions(cf);
   catch
      oldopts = [];
   end

   % Use the same starting values as were used originally
   if (~isempty(oldopts)) && ~isempty(findprop(oldopts,'StartPoint'))
      start=oldopts.StartPoint;
   end

   % Examine the fitoptions object for this fit, and compare it
   % with a new one with default settings to figure out which
   % options to reproduce in the generated code
   ndiffs = 0;
   if isempty(oldopts)
      optfields = [];
   else
      oldmethod = oldopts.method;
      if isequal(oldmethod,'None') && isa(oldopts,'curvefit.smoothoptions')
         oldmethod = 'SmoothingSpline';
      end
      newopts = fitoptions('method',oldmethod);
      opttext = '';
      defaultfields = fields(newopts);
      optfields = fields(oldopts);
      
      % Remove fields that are done separately or should be ignored
      optfields(strcmpi('startpoint',optfields)) = [];
      optfields(strcmpi('method',optfields)) = [];
      optfields(strcmpi('exclude',optfields)) = [];
      optfields(strcmpi('display',optfields)) = [];
   end
   for j=1:length(optfields)
      fname = optfields{j};
      k = find(strcmpi(fname,defaultfields));
      if length(k)==1
         optval = '';
         defval = '';
         try
            optval = get(oldopts,fname);
            if (strcmpi(fname,'lower') || strcmpi(fname,'upper')) ...
                && all(isinf(optval))
               optval = [];
            end
            defval = get(newopts,fname);
         catch
         end
         if ~isequal(optval,defval) && (~isempty(optval) || ~isempty(defval))
            ndiffs = ndiffs + 1;
            opttext = sprintf('%s,''%s'',%s',opttext,fname,...
                              cell2text(optval));
         end
      end
   end
   if ndiffs>0
      blkf{end+1} = sprintf('fo_ = fitoptions(''method'',''%s''%s);',...
                            oldmethod,opttext);
      fitargs = sprintf(',fo_%s',fitargs);
      havefitopt = 1;
   end
   
   % Add things to either the fitoptions object or the fit call
   if ~isempty(start)
      blkf{end+1} = sprintf('st_ = [%s];',sprintf('%.13g ',start));
      if havefitopt
         blkf{end+1} = 'set(fo_,''Startpoint'',st_);';
      else
         fitargs = sprintf('%s,''Startpoint'',st_',fitargs);
      end
   end
   if wtd
      if havefitopt
         blkf{end+1} = sprintf('set(fo_,''Weight'',%s);',wname);
      else
         fitargs = sprintf('%s,''Weight'',%s',fitargs,wname);
      end
   end
   if excluding
      if havefitopt
         blkf{end+1} = 'set(fo_,''Exclude'',ex_);';
      else
         fitargs = sprintf('%s,''Exclude'',ex_',fitargs);
      end
   end

   blkf{end+1} =  sprintf('ft_ = fittype(%s %s);',modeldef,ftypeargs);
   blkf{end+1} =  sprintf('\n%% Fit this model using new data');
   blkf{end+1} =  sprintf('cf_ = fit(%s,%s,ft_ %s);',...
                          xname,yname,fitargs);

   % For fits with simple coefficient representations, add a
   % helpful comment indicating what the estimates were
   categ = category(cf);
   cvals = [];
   try
      cvals = coeffvalues(cf);
   catch
   end
   if ~isequal(categ,'spline') && ~isequal(categ,'interpolant') && ~isempty(cvals)
       blkf{end+1} = sprintf('\n%% Or use coefficients from the original fit:');
       blkf{end+1} = sprintf('if 0\n   cv_ = %s;', cell2text(num2cell(cvals)));
       blkf{end+1} = sprintf('   cf_ = cfit(ft_,cv_{:});\nend\n');
   end

   % Plot the fit and bounds if the original figure had them plotted
   if ~isempty(ft.line) && ishandle(ft.line)
      propvals = get(ft.line,allprop);
      [c,m,l,w,s] = deal(propvals{:});

      if isequal(ft.line.ShowBounds,'on')
         ptype = 'predobs';
         clev = ft.line.ConfLevel;
      else
         ptype = 'fit';
         clev = 0.95;
      end
      blkf{end+1} = '% Plot this fit';
      blkf{end+1} = sprintf('h_ = plot(cf_,''%s'',%g);',ptype,clev);
      blkf{end+1} = 'legend off;  % turn off legend from plot method call';
      blkf{end+1} = sprintf(...
          'set(h_(1),''Color'',[%g %g %g],...', ...
               c(1),c(2),c(3));
      blkf{end+1} = sprintf(...
          '     ''LineStyle'',''%s'', ''LineWidth'',%d,...', ...
               l,w);
      blkf{end+1} = sprintf(...
          '     ''Marker'',''%s'', ''MarkerSize'',%d);', ...
               m,s);
      if showlegend
         blkf{end+1} = 'legh_(end+1) = h_(1);';
         blkf{end+1} = sprintf('legt_{end+1} = ''%s'';',...
                               quotedtext(fitname));
      end


      if isequal(ft.line.ShowBounds,'on')
         blkf{end+1} = 'if length(h_)>1';
         blkf{end+1} =  sprintf(...
          '   set(h_(2:end),''Color'',[%g %g %g],...', ...
               c(1),c(2),c(3));
         blkf{end+1} =  ...
          '       ''LineStyle'','':'', ''LineWidth'',1,''Marker'',''none'');';
         if showlegend
            blkf{end+1} = '   legh_(end+1) = h_(2);';
            blkf{end+1} = sprintf('   legt_{end+1} = ''Pred bnds (%s)'';',...
                                  quotedtext(fitname));
         end
         blkf{end+1} = 'end';
      end

      % Add residuals if the original figure had them
      if ~isempty(ft.rline) && ishandle(ft.rline)
         haveresiduals = 1;
         propvals = get(ft.rline,allprop);
         [c,m,l,w,s] = deal(propvals{:});
         if excluding
            blkf{end+1} =sprintf('res_ = %s(~ex_) - cf_(%s(~ex_));',...
                                 yname,xname);
            blkf{end+1} = sprintf('[x_,i_] = sort(%s(~ex_));',xname);
         else
            blkf{end+1} = sprintf('res_ = %s - cf_(%s);',yname,xname);
            blkf{end+1} = sprintf('[x_,i_] = sort(%s);',xname);
         end
         blkf{end+1} = 'axes(ax2_); hold on;';
         blkf{end+1} = sprintf(...
           'h_ = line(x_,res_(i_),''Parent'',ax2_,''Color'',[%g %g %g],...',...
                  c(1),c(2),c(3));
         blkf{end+1} = sprintf(...
             '     ''LineStyle'',''%s'', ''LineWidth'',%d,...', ...
                  l,w);
         blkf{end+1} = sprintf(...
             '     ''Marker'',''%s'', ''MarkerSize'',%d);', ...
                  m,s);
         blkf{end+1} = 'axes(ax_); hold on;';
         if showlegend
            blkf{end+1} = 'legrh_(end+1) = h_;';
            blkf{end+1} = sprintf('legrt_{end+1} = ''%s'';',...
                                  quotedtext(fitname));
         end
      end
   else
      blkf{end+1} =  '% This fit does not appear on the plot';
   end
end
% back to normal indentation

   % Move to next fit
   ft = right(ft);
end

% In setup section, create either one or two axes
if haveresiduals
   blks{end+1} = 'ax_ = subplot(2,1,1);';
   blks{end+1} = 'ax2_ = subplot(2,1,2);';
   blks{end+1} = 'set(ax2_,''Box'',''on'');';
   if showlegend
      blks{end+1} = 'legrh_ = []; legrt_ = {};';
   end
else
   blks{end+1} = 'ax_ = subplot(1,1,1);';
end
blks{end+1} = 'set(ax_,''Box'',''on'');';
if isequal(cfgetset('showgrid'),'on')
   blks{end+1} = 'grid(ax_,''on'');';
   if haveresiduals
      blks{end+1} = 'grid(ax2_,''on'');';
   end
end
blks{end+1} = 'axes(ax_); hold on;';

% At end of data set section, set x axis limits
blkd{end+1} = sprintf('\n%% Nudge axis limits beyond data limits');
blkd{end+1} = 'if all(isfinite(xlim_))';
blkd{end+1} = '   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);';
blkd{end+1} = '   set(ax_,''XLim'',xlim_)';
if haveresiduals
   blkd{end+1} = '   set(ax2_,''XLim'',xlim_)';
end
blkd{end+1} = 'end';


% Finish up
blke{end+1} = 'hold off;';
if showlegend
   blke{end+1} = 'legend(ax_,legh_, legt_);';
   if haveresiduals
      blke{end+1} = 'legend(ax2_,legrh_, legrt_);';
   end
end

% Write code into m file
if length(arglist)==0
   argtext = '';
else
   argtext = sprintf('%s,',arglist{:});
   argtext = sprintf('(%s)',argtext(1:end-1));
end
if length(arglist)>=2
   arglist(1:2) = [];
end
[fid,msg] = fopen(mfilename,'w');
if fid==-1
   emsg = sprintf('Error trying to write to %s:\n%s',mfilename,msg);
   errordlg(emsg,'Error Generating M-file','modal');
   return
end
fprintf(fid,'function %s%s\n',fcnname,argtext);
fprintf(fid,'%%%s    Create plot of datasets and fits\n',upper(fcnname));
fprintf(fid,'%%   %s%s\n',upper(fcnname),upper(argtext));
fprintf(fid,'%%   Creates a plot, similar to the plot in the main curve fitting\n');
fprintf(fid,'%%   window, using the data that you provide as input.  You can\n');
fprintf(fid,'%%   apply this function to the same data you used with cftool\n');
fprintf(fid,'%%   or with different data.  You may want to edit the function to\n');
fprintf(fid,'%%   customize the code and this help message.\n');
fprintf(fid,'%%\n');
fprintf(fid,'%%   Number of datasets:  %d\n',nds);
fprintf(fid,'%%   Number of fits:  %d\n',nfit);
fprintf(fid,'\n');
for j=1:length(blkc)
   fprintf(fid,'%s\n',xlate(blkc{j}));
end
fprintf(fid,'%%\n');
fprintf(fid,'%% This function was automatically generated on %s\n',...
            datestr(now));
fprintf(fid,'\n');
for j=1:length(blks)
   fprintf(fid,'%s\n',xlate(blks{j}));
end
fprintf(fid,'\n');
for j=1:length(blkd)
   fprintf(fid,'%s\n',xlate(blkd{j}));
end
fprintf(fid,'\n');
for j=1:length(blkf)
   fprintf(fid,'%s\n',xlate(blkf{j}));
end
fprintf(fid,'\n');
for j=1:length(blke)
   fprintf(fid,'%s\n',xlate(blke{j}));
end
fclose(fid);

% ------------------- double up quotes in text string
function a = quotedtext(b)
if ischar(b)
   a = strrep(b,'''','''''');
else
   a = sprintf('%.13g',b);
end

% ------------------- create text to re-create cell array
function a = cell2text(b)

if ~iscell(b)
   if ischar(b)
      a = sprintf('''%s''',quotedtext(b));
   elseif length(b)==1
      a = sprintf('%.13g',b);
   else
      numtext = num2str(b,'%.13g ');
      if size(numtext,1)>1
         numtext = [numtext repmat(';',size(numtext,1),1)]';
         numtext = numtext(:)';
         numtext = numtext(1:end-1);
      end
      a = sprintf('[%s]',numtext);
   end
   return
end

if length(b)>0
   bj = b{1};
   if ischar(bj)
      a = sprintf('''%s''',quotedtext(bj));
   else
      a = sprintf('%.13g',bj);
   end
   for j=2:length(b)
      bj = b{j};
      if ischar(bj)
         a = sprintf('%s, ''%s''',a,quotedtext(bj));
      else
         a = sprintf('%s, %.13g',a,bj);
      end
   end
else
   a = '';
end
a = sprintf('{%s}',a);

% ------------------- create text to generate a list of rows
function t = makerowspec(v)

% Find the start and end of each sequence
rownums = find(v(:));
n = length(v);
t = '';

if length(rownums)>0
   diffs = diff(rownums);
   starts = rownums(logical([1;(diffs>1)]));
   ends   = rownums(logical([(diffs>1);1]));
   
   % Create some text to reproduce this sequence
   for j=1:length(starts)
      if starts(j) == ends(j)
         t = sprintf('%s %d',t,starts(j));
      elseif starts(j) == ends(j)-1
         t = sprintf('%s %d %d',t,starts(j),ends(j));
      else
         t = sprintf('%s (%d:%d)',t,starts(j),ends(j));
      end
   end
   t = t(2:end);
end

t = sprintf('[%s]',t);


% ------------------- create text to represent a comparison
function t = makecomptxt(xname,txtlo,oplo,txthi,ophi)

% Set up
ops = {'<' '<='};
xlo = [];
xhi = [];

% If there's a lower bound, deal with it
if ~isempty(txtlo)
   xlo = str2double(txtlo);
   if ~isfinite(xlo)
      xlo = [];
   end
   op1 = ops{1+oplo};
end         

% If there's an upper bound, deal with it
if ~isempty(txthi)
   xhi = str2double(txthi);
   if ~isfinite(xhi)
      xhi = [];
   end
op2 = ops{1+ophi};
end

% Combine whatever bounds we have
if ~isempty(xlo) && ~isempty(xhi)
   t = sprintf('~(%.13g%s%s & %s%s%.13g)',...
               xlo,op1,xname,xname,op2,xhi);
elseif ~isempty(xlo)
   t = sprintf('~(%.13g %s %s)',xlo,op1,xname);
elseif ~isempty(xhi)
   t = sprintf('~(%s %s %.13g)',xname,op2,xhi);
else
   t = '';
end

