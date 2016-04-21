function epsilon = METLINESdefinepermittivity(omesh,basevalue,varargin);

##
##
## epsilon = METLINESdefinepermittivity(omesh,basevalue,[regions1, value1,...]);
##
##

load (file_in_path(path,'constants.mat'));
epsilon = e0*basevalue*ones(size(omesh.t(1,:)))';

for ii=1:floor(length(varargin)/2)
  [ignore1,ignore2,elements]=Usubmesh(omesh,[],varargin{2*ii-1},1);
  epsilon(elements) = varargin{2*ii}*e0;
end
