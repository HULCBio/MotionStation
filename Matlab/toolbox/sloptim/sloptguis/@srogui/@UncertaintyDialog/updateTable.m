function updateTable(this)
% Updates contents of Uncertain Parameters frame

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:21 $
ActiveSpec = this.ActiveSpec;
USpec = this.Uncertainty(ActiveSpec);
np = length(USpec.Parameters);
switch ActiveSpec
   case 1
      % Random set
      Data = cell(max(10,np),4);
      for ct=1:np
         p = USpec.Parameters(ct);
         Data(ct,:) = {p.Name p.Nominal p.Min p.Max};
      end
      % Number of samples
      set(this.Figure.UserData.NumSample(1),'String',USpec.NumSamples)
   case 2
      % Grid
      Data = cell(max(10,np),3);
      for ct=1:np
         p = USpec.Parameters(ct);
         Data(ct,:) = {p.Name p.Nominal p.Values};
      end
      % Compute number of samples
      try
         % Get list of variable names in model workspace
         ModelWS = get_param(this.Project.Model,'ModelWorkspace');
         s = whos(ModelWS);
         ModelWSVars = {s.name};
         % Evaluate spec and get number of samples
         if isempty(USpec.Parameters)
            ns = '0';
         else
            uset = evalForm(USpec,ModelWS,ModelWSVars);
            ns = num2str(prod(getGridSize(uset)));
         end
      catch
         ns = 'N/A';
      end
      set(this.Figure.UserData.NumSample(2),'String',ns)
end

% Update table data
% RE: Protected to avoid triggering DataChangedCallback 
Table = this.Figure.UserData.Table(ActiveSpec);
CB = get(Table,'DataChangedCallback');
set(Table,'DataChangedCallback',''), drawnow
set(Table,'Data',Data), drawnow
set(Table,'DataChangedCallback',CB)


