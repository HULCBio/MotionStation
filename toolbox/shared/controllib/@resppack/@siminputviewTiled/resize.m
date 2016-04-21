function resize(this,Ny)
%RESIZE  Adjusts input plot to fill all available rows.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:45 $
Curves = this.Curves;
nobj = length(Curves);
if nobj>Ny
   delete(Curves(Ny+1:nobj))
   this.Curves = Curves(1:Ny);
else
   p = this.Curves(1).Parent;
   for ct=Ny:-1:nobj+1
      % UDDREVISIT
      Curves(ct,1) = handle(copyobj(Curves(1),p));
   end
   this.Curves = Curves;
end