function n = name(self,varargin)
 if nargin == 1
   n = ncname(self);
 else
   ncname(self,varargin{:});
 end
end
