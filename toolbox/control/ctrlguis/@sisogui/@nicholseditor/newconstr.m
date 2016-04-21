function out = newconstr(Editor, keyword, CurrentConstr)
%NEWCONSTR  Interface with dialog for creating new constraints.
%
%   LIST = NEWCONSTR(Editor) returns the list of all available
%   constraint types for this editor.
%
%   CONSTR = NEWCONSTR(Editor,TYPE) creates a constraint of the 
%   specified type.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Revised: 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:05:34 $

if nargin == 1
   % Return list of valid constraints
   out = {'Phase Margin'; 'Gain Margin'; 'Closed-Loop Peak Gain'};
else
   switch keyword
   case 'Phase Margin'
      Class = 'plotconstr.nicholsphase';
      
   case 'Gain Margin'
      Class = 'plotconstr.nicholsgain';
      
   case 'Closed-Loop Peak Gain'
      Class = 'plotconstr.nicholspeak';
   end
   
   % Create instance
   if nargin > 2 & isa(CurrentConstr, Class)
      % Recycle existing instance
      Constr = CurrentConstr;  
   else
      % Create new instance
      Constr = feval(Class);
   end
   
   % Attach to editor axes
   Constr.Parent = getaxes(Editor.Axes);
   out = Constr;
end
