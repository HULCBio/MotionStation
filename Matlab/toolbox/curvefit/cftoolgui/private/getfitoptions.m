function getfitoptions(cftoolFit,model,dataSetName,excludeSetName)
% GETFITOPTIONS creates a new fitoptions object that can be applied to this
% cftoolFit and stores a bunch of stuff in properties of the fitdb.

% $Revision: 1.9.2.1 $  $Date: 2004/02/01 21:40:22 $
% Copyright 2001-2004 The MathWorks, Inc.

cftoolFit=handle(cftoolFit);
fitdb=getfitdb;

% Get the curvefit.fitoptions to be edited in the editor and applied.
if nargin==1
   % opening an existing cftoolFit
   newOptions=copy(cftoolFit.fitOptions);
   model=type(cftoolFit.fit);
   if isequal(model,'customlinear') | isequal(model,'customnonlinear')
      model=['custom: ' cftoolFit.hint];
      customEquation = cftoolFit.hint;
   end
   dataSetName=get(get(cftoolFit,'dshandle'),'name');
else
   % creating a new cftoolFit
   if strmatch('custom: ',model)
      % this is a custom model
      customEquation = model(9:end);
      newOptions=managecustom('getopts',customEquation);
   else
      % this is a library model
      newOptions=fitoptions(model);  
      if ~isempty(findprop(newOptions,'StartPoint'))
         if isempty(dataSetName)
            % dataSetName can be empty if no datasets yet been imported.
            newOptions.StartPoint=[];
         else
            newOptions.StartPoint=getstartpoint(model,dataSetName,excludeSetName);
         end
      end
   end
end

% Get the coefficient names of the fittype for easy access from java.
if strmatch('custom: ',model)
   if isempty(customEquation)
      % No equation is selected in the listbox, i.e. it's empty.
      newCoeff={};
   else
      newCoeff=coeffnames(fittype(managecustom('get',customEquation)));
   end
else
   newCoeff=coeffnames(fittype(model));
end

% Get the list of properties.  We could get this through bean introspection, 
% but the properties come back in a seemingly random order.
if isempty(newOptions)
   newProps={};
else
   newProps=fieldnames(get(newOptions));
end

% For lack of a better place, save all this in properties of the fitdb.
fitdb.newModel=model;
fitdb.newCoeff=newCoeff;
fitdb.newProps=newProps;
% this must be set last, since it triggers the Fit Options Editor to update
fitdb.newOptions=newOptions;
