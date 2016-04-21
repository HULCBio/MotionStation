function v = par2var(this)
% Serializes tuned parameter data (vector P of parameter objects)
% into design variable data for optimizers.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:45:31 $
Proj = this.Project;
ParData = Proj.Parameters;
x0 = [];
lb = [];
ub = [];
Sx = [];

% Get initial value, typical value, and bounds for tuned parameters
for ct=1:length(ParData)
   p = ParData(ct);
   idxt = find(p.Tuned);
   if ~isempty(idxt)
      % Initial guess
      val = p.InitialGuess(idxt);
      x0 = [ x0 ; val(:)];

      % Min/max
      val = p.Minimum(idxt);
      lb = [ lb ; val(:)];
      val = p.Maximum(idxt);
      ub = [ ub ; val(:)];

      % Scaling
      val = p.TypicalValue(idxt);
      Sx = [ Sx ; val(:)];
   end
end

% Design variable structure
v = struct(...
   'Initial', x0, ...
   'Minimum', lb, ...
   'Maximum', ub, ...
   'Typical', Sx);
