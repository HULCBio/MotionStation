function localize(this)
%LOCALIZE  Updates @siminput wave when plot size changes.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:31 $
Ny = length(getrcname(this.Parent));  % row size

if length(this.RowIndex)~=Ny
   % Expand input plot to fill all available rows
   set(this.Listeners,'Enable','off')
   this.RowIndex = 1:Ny;
   set(this.Listeners,'Enable','on')
   
   % Adjust number of curves to match output dimension
   for v = this.View'
      resize(v,Ny)
   end
   for c = this.Characteristics'
      for v = c.View'
         resize(v,Ny)
      end
   end
   
   % Update graphics
   reparent(this)
end
