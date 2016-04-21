function addpar(this,Name,Nominal)
% Adds parameter to grid.

%   $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:08 $
%   Copyright 1986-2004 The MathWorks, Inc.
this.Parameters = [this.Parameters;...
   struct('Name',Name,'Nominal',mat2str(Nominal,4),'Values',Name)];
