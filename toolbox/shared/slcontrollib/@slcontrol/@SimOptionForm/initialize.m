function initialize(this,Model)
% Initializes simulation options from a given model.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:58 $
%   Copyright 1986-2004 The MathWorks, Inc.
ModelOptions = simget(Model);
Props = intersect(fieldnames(this),fieldnames(ModelOptions));
for ct=1:length(Props)
   f = Props{ct};
   if isa(ModelOptions.(f),'char')
      this.(f) = ModelOptions.(f);
   else
      this.(f) = num2str(ModelOptions.(f),8);
   end
end
