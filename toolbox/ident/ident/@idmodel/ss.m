function ssmodel = ss(idmodel,noi)
% IDMODEL/SS Transformation to the LTI/SS format
%
%   SYS = SS(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, or IDGREY)
%   SYS is in the Control System Toolbox's LTI/SS object format.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = SS(MODEL('Measured')) or SYS = SS(MODEL,'M') 
%   ignores the noise inputs.
%
%   SYS = SS(MODEL('noise')) gives a representation of the noise
%   channels only.
%
%   See also IDSS.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $  $Date: 2004/04/10 23:17:43 $

if nargin>1
    idmodel = idmodel('m');
end
if ~exist('@ss/ss')
   error('This function requires the Control Systems Toolbox.')
end
% $$$ if ~isreal(idmodel)
% $$$    error(sprintf(['The LTI objects cannot represent complex data.',...
% $$$          '\nUse model.par = real(model.par) and/or model.par = imag(model.par)',...
% $$$          '\nand then ss(model) to select the real and imagary parts of the model.']))
% $$$ end

[ny,nu] = size(idmodel);
 
lam = idmodel.NoiseVariance;
idmodel.CovarianceMatrix = []; % to avoid unneccesary calculations
%if isa(idmodel,'idarx') % To avoid extra states from noise input
   idmodel = idss(idmodel);
%end

was = warning;
warning off
idmodel = idmodel(:,'allx9');

[a,b,c,d]=ssdata(idmodel); 
ssmodel = ss(a,b,c,d,'Ts',idmodel.Ts);
warning(was)

if norm(lam)>0
    if nu>0
        if isstruct(get(ssmodel,'InputGroup'))
            inpg.Measured=[1:nu];
            inpg.Noise = [nu+1:nu+ny];
            set(ssmodel,'InputGroup',inpg);
        else
            set(ssmodel,'InputGroup',{1:nu,'Measured';nu+1:nu+ny,'Noise'})
        end
    else
        if isstruct(get(ssmodel,'InputGroup'))
            inpg.Noise = [1:ny];
            set(ssmodel,'InputGroup',inpg);
        else
            set(ssmodel,'InputGroup',{1:ny,'Noise'});
        end
    end
end
 inpd = idmodel.InputDelay;
 if any(inpd<0)
     warning(sprintf(['LTI/SS objects do not accept negative InputDelay.\n',...
         'Negative InputDelay has been set to zero.']))
 inpd = max(0,inpd);
end
set(ssmodel,'InputName',idmodel.InputName,'OutputName',idmodel.OutputName,...
     'InputDelay',inpd)
if isa(idmodel,'idss')|isa(idmodel,'idgrey')
    set(ssmodel,'StateName',pvget(idmodel,'StateName'))
end
% set inputname, etc

