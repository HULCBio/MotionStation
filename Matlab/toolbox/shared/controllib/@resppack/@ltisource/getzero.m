function [z,k] = getzero(this,idx)
%GETZERO   Extracts zero/gain data for model #idx.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:55 $
if isempty(this.ZPKData(idx).Zero)
   % Recompute z,k data
   try
      % REVISIT
      s = this.ZPKData;
      [s(idx).Zero,s(idx).Gain] = iozero(this.Model(:,:,idx));
      this.ZPKData = s;
   end
end
z = this.ZPKData(idx).Zero;
k = this.ZPKData(idx).Gain;