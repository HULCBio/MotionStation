function FPE1 = fpe(varargin)
%FPE Extracts the Final Pediction Error from a model
%   FPE = FPE(Model)
%
%   Model = Any IDMODEL (IDGREY, IDARX, IDPOLY, or IDSS)
%
%   FPE = Akaikes Final Predition Error = V*(1+d/N)/(1-d/N)
%   where V is the loss function, d is the number of estimated paramters
%   and N is the number of estimation data.
%
%   See also AIC.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/10 23:17:23 $
FPE=[];
for kk = 1:length(varargin)
    model = varargin{kk};
    if ~isa(model,'idmodel')
        error('Only idmodels can be used as arguments in FPE.')
    end
    try
        FPEk = model.EstimationInfo.FPE;
    catch
        FPEk = [];
    end
    FPE = [FPE,FPEk];
end
if nargout
    FPE1 = FPE;
else
    disp(FPE)
end

