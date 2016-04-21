function setOptimized(this,Config)
% Helper function for specifying which parameter configurations should 
% be included in the optimization.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:43 $
switch Config
   case 'none'
      this.Optimized = false;
   case 'all'
      this.Optimized = true;
   case 'vertex'
      % Only avalaible for gridded domain
      if length(this.Grid_)==1 && isempty(this.Grid_.Variable)
         % Scattered data
         npars = length(getParNames(this));
         Optimized = this.Optimized;
         Optimized(1:2^npars) = true;
         Optimized(2^npars+1:end) = false;
      else
         gs = getGridSize(this);
         % Construct vertex indexing matrix
         idx = [1;gs(1)];
         for ct=2:length(gs)
            nr = size(idx,1);
            idx = [idx ones(nr,1);idx zeros(nr,1)+gs(ct)];
         end
         % Convert to absolute indices
         idx = 1 + (idx-1) * cumprod([1 gs(1:end-1)]).';
         Optimized = false(gs);
         Optimized(idx) = true;
      end
      this.Optimized = Optimized;
end
      
      
      