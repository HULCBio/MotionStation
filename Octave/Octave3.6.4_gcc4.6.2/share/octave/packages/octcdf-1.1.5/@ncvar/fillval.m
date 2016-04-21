function n = fillval(self,varargin)
 if nargin == 1
   n = ncfillval(self);
 else
   ncfillval(self,varargin{:});
 end
end
