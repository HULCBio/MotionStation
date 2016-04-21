function [z,p] = getpz(this,idx)
%GETPZ   Accesses pole/zero data for model #idx.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:52 $

D = this.Dynamics(idx);

if isempty(D.Poles)
   % Recompute pole/zero data (for each I/O pair)
   % REVISIT disp(sprintf('Computing poles and zeros for model # %d',idx))
   try
       [z,p] = zpkdata(this.Model(:,:,idx));
       % Keep single copy of poles if equal for all I/Os
       if prod(size(p))>1 & isequal(p{:})
           p = p(1);
       end
   catch
       % For FRD's and related (immaterial)
       z = [];  p = [];
   end
    
   % Store updated pole/zero data
   % REVISIT
   Dyn = this.Dynamics;
   Dyn(idx).Zeros = z;
   Dyn(idx).Poles = p;
   this.Dynamics = Dyn;
   
else
   % Read data
   z = D.Zeros;
   p = D.Poles;
   
end

   
   