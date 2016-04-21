function p = getpole(this,idx)
%GETPOLE   Extracts poles of model #idx.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:51 $
if isempty(this.ZPKData(idx).Pole)
   % Recompute zpk model
   try
      % REVISIT
      s = this.ZPKData;
      s(idx).Pole = iopole(this.Model(:,:,idx));
      this.ZPKData = s;
   end
end
p = this.ZPKData(idx).Pole;