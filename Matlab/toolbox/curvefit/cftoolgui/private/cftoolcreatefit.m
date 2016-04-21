function [cftoolFit, results, isgood, fitOptions, hint]=cftoolcreatefit(cftoolFit,panel,method,normalize,arg1,dataset,outlier,fitname)

% $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:40:09 $
% Copyright 2001-2004 The MathWorks, Inc.

% convert the java UDDObject to something that m-code likes
% and set new properties.
cftoolFit=handle(cftoolFit);
cftoolFit.name=fitname;
cftoolFit.dataset=dataset;
cftoolFit.outlier=outlier;

% define a couple of useful variables
thefitdb=getfitdb;
dataset=find(getdsdb,'name',cftoolFit.dataset);

% clear everything out
cftoolFit.plot=0;
f=cfit; g=[]; out=[];
warnstr=[]; errstr=[]; convmsg = [];
results='';

% pull the new fitoptions to use from where they have been stored on the fitdb
fitOptions=thefitdb.newOptions;

% set normalize
fitOptions.Normalize = normalize;

% convert the custom method string into the corresponding fittype object
if length(method) > 7 & isequal(method(1:8),'custom: ')
   equationName=method(9:end);
   method = managecustom('get',equationName);
end

% set (or clear) the smoothing parameter
if isequal(method,'smoothing')
   sp=str2double(arg1);
   if ~isnan(sp)
      fitOptions.smoothingparam=sp;
   else
      fitOptions.smoothingparam=[];
   end
end

% Set up other fitoptions
fitOptions.weights=dataset.weight;

% if this method has a display, turn it off
if ~isempty(findprop(fitOptions,'Display'))
   fitOptions.Display='off';
end

% Exclude points if requested
if ~isequal(cftoolFit.outlier,'(none)')
   outset = find(getoutlierdb,'name',cftoolFit.outlier);
   fitOptions.Exclude = cfcreateexcludevector(dataset,outset);
else
   fitOptions.Exclude = cfcreateexcludevector(dataset,[]);
end

%% DO THE FIT %%
[f,g,out,warnstr,errstr,convmsg]=fit(dataset.X,dataset.Y,method,fitOptions);

% CreateAFit uses hint to set up the state of the paramter panel when opening 
% an existing fit.
if ischar(method) & isequal(method(1:3),'rat')
   hint=method(4:5);
elseif isequal(method,'smoothing') & isnan(sp) & isstruct(out)
   % The fit command used the default smoothing parameter.  Stick
   % this back into the cftool.fit object's hint for later use.
   hint=sprintf('%g',out.p);
else
   hint=num2str(arg1);
end

% Store all the information about this fit back into the cftool.fit object.
cftoolFit.fit=f;
cftoolFit.fitOptions=fitOptions;
cftoolFit.goodness=g;
cftoolFit.output=out;
cftoolFit.dataset=dataset.name;
cftoolFit.dshandle=dataset;
cftoolFit.type=panel;
%cftoolFit.name=fname;
cftoolFit.hint=hint;

% reset goodness of fit measures
cftoolFit.sse=NaN;
cftoolFit.rsquare=NaN;
cftoolFit.dfe=NaN;
cftoolFit.adjsquare=NaN;
cftoolFit.rmse=NaN;
cftoolFit.ncoeff=NaN;

% Check to see if a fit was created
if ~isempty(f)
   % A fit was created, this is good, :)
   cftoolFit.isGood=logical(1);
   cftoolFit.sse=g.sse;
   cftoolFit.rsquare=g.rsquare;
   if isfield(g,'dfe')
      cftoolFit.dfe=g.dfe; 
   else 
      cftoolFit.dfe=0; 
   end
   cftoolFit.adjsquare=g.adjrsquare;
   cftoolFit.rmse=g.rmse;
   if ~isempty(out.numparam)
      cftoolFit.ncoeff=out.numparam;
   end
   if isfield(out,'R')
      cftoolFit.R = out.R;
   elseif isfield(out,'Jacob')
      [Q,R] = qr(Jacob);
      cftoolFit.R = R;
   end
   % Plot the line
   set(cftoolFit.line,'String',cftoolFit.name);
   cftoolFit.plot=1;
else
   % A fit was not created, this is not good, :(
   cftoolFit.isGood=logical(0);
   % Clear the type out so that CreateAFit will treat it as a "new" fit when 
   % it opens it in the editor.
   cftoolFit.type='';
   % Clear the dataset so it doesn't show up in the table of fits.
   cftoolFit.dataset='';
end
clev = cfgetset('conflev');
results=genresults(f,g,out,warnstr,errstr,convmsg,clev);
results=sprintf('%s\n',results{:});

cftoolFit.results=results;

% Wrap the cftool.fit object up so the java code can handle it as a UDDObject.
isgood = cftoolFit.isGood;
cftoolFit=java(cftoolFit);
fitOptions = java(fitOptions);

