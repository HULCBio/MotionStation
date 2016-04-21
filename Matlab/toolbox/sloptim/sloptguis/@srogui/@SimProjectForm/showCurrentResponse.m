function showCurrentResponse(this)
% Collects response data and issues request for plotting 
% current response of a particular test.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:45:08 $
try
   % Evaluate project spec (creates runnable project)
   Proj = evalForm(this);

   % Notify peers of runtime project creation
   E = ctrluis.dataevent(this,'SourceCreated',Proj);
   this.send('SourceCreated',E)

   % Initialize data logging settings
   logSave(Proj)

   % Grab current parameter values
   Proj.evalin(Proj.Parameters)
   % Get data
   for ct=1:length(Proj.Tests)
      t = Proj.Tests(ct);  % runnable test
      if strcmp(t.Enable,'on')
         % Simulate
         DataLog = getCurrentResponse(t);
         % Notify constraint editors to update their plots
         % RE: Event issued by @SimTestForm test spec
         E = ctrluis.dataevent(t,'ShowCurrent',DataLog);
         t.send('ShowCurrent',E)
      end
   end

   % Restore data logging settings
   logRestore(Proj)
catch
   errordlg(utGetLastError,'Simulation Error','modal')
end
