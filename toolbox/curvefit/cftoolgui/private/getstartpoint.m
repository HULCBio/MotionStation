function sp=getstartpoint(model,dataSetName,excludeSetName)
% GETSTARTPOINT returns the default starting point.

% $Revision: 1.5.2.2 $  $Date: 2004/02/01 21:40:23 $
% Copyright 2001-2004 The MathWorks, Inc.

if length(model) > 7 && isequal(model(1:8),'custom: ')
   equationName=model(9:end);
   sp=get(managecustom('getopts',equationName),'startpoint');
else
   dataSet=find(getdsdb,'name',char(dataSetName));
   ft=fittype(model);
   h=constants(ft);
   spfun=startpt(ft);
   if ~isempty(spfun)
      % Exclude points if requested
      if ~isequal(excludeSetName,'(none)')
         outset=find(getoutlierdb,'name',excludeSetName);
         include=~cfcreateexcludevector(dataSet,outset);
      else
         include=~cfcreateexcludevector(dataSet,[]);
      end
      x=dataSet.x;
      y=dataSet.y;
      % Turn warnings off to avoid messages like this:
      % Warning: Power functions require x to be positive. ...
      warnstate=warning('off', 'all');
      sp=feval(spfun,x(include),y(include),h{:});
      warning(warnstate);
   else
      % Use random start points if necessary
      sp = rand(1,numcoeffs(ft));
   end
end
