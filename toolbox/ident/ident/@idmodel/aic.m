function AIC1 = aic(varargin)
%AIC Computes Akaike's Information Criterion(AIC) from a model
%   AIC = AIC(Model)
%
%   Model = Any IDMODEL (IDGREY, IDARX, IDPOLY, or IDSS)
%
%   AIC = Akaikes Information Criterion log(V) + 2d/N  
%   where V is the loss function, d is the number of estimated paramters
%   and N is the number of estimation data.
%
%   See also FPE.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/10 23:17:16 $

AIC=[];
for kk = 1:length(varargin)
    model = varargin{kk};
    if ~isa(model,'idmodel')
        error('Only idmodels can be used as arguments in AIC.')
    end
    try
        AICk =1;
        FPE = model.EstimationInfo.FPE;
        N = model.EstimationInfo.DataLength;
        V = model.EstimationInfo.LossFcn;
    catch
        AICk = [];
    end
    if ~isempty(AICk)
        Nnpar = ((FPE/V)-1)/((FPE/V)+1);
        AICk = log(V)+2*Nnpar;
    end
    AIC = [AIC,AICk];
end
if nargout
    AIC1 = AIC;
else
    disp(' ')
    disp(AIC)
end

