function clearplot(this,idxTest)
% Clears current plot and optimization trace

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:41 $
if nargin==1
   % Clear all
   for ct=1:length(this.TestViews)
      clearplot(this,ct)
   end
else
   % Clear response associated with particulat test
   View = this.TestViews(idxTest);
   % Current response
   set(View.Response,'XData',[],'YData',[],'Zdata',[])
   % Optim trace
   delete(View.Optimization(:))
   this.TestViews(idxTest).Optimization = [];
end
