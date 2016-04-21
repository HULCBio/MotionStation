function this = ParameterForm(Name,Ref)
% Constructor

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:12 $
ni = nargin;
this = srogui.ParameterForm;
if ni==0
   % Call when reloading object
   return
end
this.Name = Name;
this.Value = Name;
this.InitialGuess = Name;
this.Min = '-Inf';
this.Max = 'Inf';
this.TypicalValue = Name;
this.Tuned = 'true';
if ni==2
   this.ReferencedBy = Ref;
end

