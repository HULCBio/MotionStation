function result = subsref(sys,Struct)
%SUBSREF  Subsref method for IDPROC models
%   The following reference operations can be applied to any IDMODEL
%   object MOD:
%      MOD(Outputs,Inputs)     select subsets of I/O channels.
%      MOD.Fieldname           equivalent to GET(MOD,'Filedname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in MOD(1,[2 3]).inputname or
%   MOD.cov(1:3,1:3)
%
%   The channel reference can be made by numbers or channel names:
%     MOD('velocity',{'power','temperature'})
%   For single output systems MOD(ku) selects the input channels ku
%   while for single input systems MOD(ky) selcets the output 
%   channels ky.
%
%   MOD('measured') selects just the mesured input channels and 
%       ignores the noise inputs.
%   MOD('noise') gives a time series (no measured input channels)
%       description of the additive noise properties of MOD.
%
%   To jointly address measured and noise channels, first convert
%   the noise channels using NOISECNV.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/10 23:18:08 $

StrucL = length(Struct);
mg = sys.idgrey;
switch Struct(1).type
    case '.'
        try
            tmpval = get(sys,Struct(1).subs);
        catch
            error(lasterr)
        end
        if StrucL==1
            result = tmpval;
        else
            result = subsref(tmpval,Struct(2:end));
        end
    case '()'
        
        try
            if StrucL==1, 
                result = indexref(sys,Struct(1).subs);
            else
                result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
            end
        catch
            error(lasterr)
        end
        
    otherwise
        error(['Unsupported type ' Struct(1).type])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,index)
if isempty(sys)
    return 
end

lam = pvget(sys,'NoiseVariance');
%lam1 = lam;
ny = size(lam,1);
[a,b] = ssdata(sys);
nu = size(b,2);
try
    [yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
        subndeco(pvget(sys,'idmodel'),index,lam);
catch
    error(lasterr)
end
if flagnoise
    di = pvget(sys,'DisturbanceModel');
    if ischar(di)
        sys = [];
    else
        sys = di{2};
        sys = tsflag(sys,'set');
    end
    return
end
if flagmea
    file = pvget(sys,'FileArgument');
    sys = pvset(sys,'DisturbanceModel','None','NoiseVariance',0);
    % Remove also the noise-parameter covariances if present:
    covv = pvget(sys,'CovarianceMatrix');
    if ~ischar(covv)&~isempty(covv)
        switch file{3}
            case 'ARMA1'
                covv = covv(1:end-2,1:end-2);
                sys = pvset(sys,'CovarianceMatrix',covv);
            case 'ARMA2'
                covv = covv(1:end-4,1:end-4);
                sys = pvset(sys,'CovarianceMatrix',covv);
        end
    end
    % Now fix idpoly if any:
ut = pvget(sys,'Utility');
try
    pol = ut.Idpoly;
catch
    pol = [];
end
if ~isempty(pol)
    polte = pol{1};
    
                       % you cannot deal with extra inputs being fake outputs.
            if norm(pvget(sys,'NoiseVariance'))==0
                pol1{1}=polte(1,uind);
            else
            pol1{1}=polte(1,[uind,nu]);%%LL was nu+yind
        end
        ut.Idpoly = pol1;
        sys=pvset(sys,'Utility',ut);
    end
    return
end
if flagboth
    sys = setnoime(sys);
    return
end
if flagall
    sys = idpoly(sys);
    sys = sys(:,'allx9');
    return
end
if returnflag
    if returnflag==2
        sys = idgrey;
    elseif returnflag ==3
        sys = [];
    end
    return
end
covv = pvget(sys,'CovarianceMatrix');
pnameorig = pvget(sys,'PName');
sys1 = setpname(sys);
pnamedef = pvget(sys1,'PName');
[p1,p2,p3,p4,p5,p6,p7,p8]=procpar(sys);
type = i2type(sys);%.Type;
pars1 = [p1,p2,p3,p4,p5,p6,p7,p8]';
pars1 = pars1(:,uind);
file = pvget(sys,'FileArgument');
[pars,typec,pnr,dnr] = parproc(pars1(:),type(uind));
sys.Kp.status = sys.Kp.status(uind);
sys.Kp.max = sys.Kp.max(uind);
sys.Kp.min = sys.Kp.min(uind);
sys.Tp1.status = sys.Tp1.status(uind);
sys.Tp1.max = sys.Tp1.max(uind);
sys.Tp1.min = sys.Tp1.min(uind);
sys.Tp2.status = sys.Tp2.status(uind);
sys.Tp2.max = sys.Tp2.max(uind);
sys.Tp2.min = sys.Tp2.min(uind);
sys.Tp3.status = sys.Tp3.status(uind);
sys.Tp3.max = sys.Tp3.max(uind);
sys.Tp3.min = sys.Tp3.min(uind);
sys.Tw.status = sys.Tw.status(uind);
sys.Tw.max = sys.Tw.max(uind);
sys.Tw.min = sys.Tw.min(uind);
sys.Zeta.status = sys.Zeta.status(uind);
sys.Zeta.max = sys.Zeta.max(uind);
sys.Zeta.min = sys.Zeta.min(uind);
sys.Tz.status = sys.Tz.status(uind);
sys.Tz.max = sys.Tz.max(uind);
sys.Tz.min = sys.Tz.min(uind);
sys.Td.status = sys.Td.status(uind);
sys.Td.max = sys.Td.max(uind);
sys.Td.min = sys.Td.min(uind);
sys.Integration = sys.Integration(uind);
sys.InputLevel.status = sys.InputLevel.status(uind);
sys.InputLevel.max = sys.InputLevel.max(uind);
sys.InputLevel.min = sys.InputLevel.min(uind);
sys.InputLevel.value = sys.InputLevel.value(uind);



file{1}=type(uind);
file{5} = pnr;
file{6} = dnr;
oldinters = file{2};
if iscell(oldinters)
    file{2} = oldinters(uind);
else
file{2} = oldinters;
end
% file(3) distmodel not touched
% file(4) distm par not touched
% file{7} = parameter bounds  Set in pem.
file{8} = sys.InputLevel;
%now dist model
parorig = pvget(sys,'ParameterVector');
switch file{3}
    case 'ARMA1'
        dmpar = parorig(end-1:end);
        dmpnr = length(parorig)-1:length(parorig);
    case 'ARMA2'
        dmpar = parorig(end-3:end);
        dmpnr = length(parorig)-3:length(parorig);
    otherwise
        dmpar =[];
        dmpnr = [];
end
pars = [pars;dmpar];
idm = pvget(sys,'idmodel');
% Now find the parameter indeces that have been selected
pnr = [];
for ku=uind
    for kpn = 1:length(pnamedef)
        strkp = findstr(pnamedef{kpn},['(',int2str(ku),')']);
        if ~isempty(strkp)
            pnr = [pnr;kpn];
        end
    end
    
end
pnr = [pnr;dmpnr'];
if ~ischar(covv)&~isempty(covv);
    covv = covv(pnr,pnr);
end
%sys = pvset(sys,'PName',pnameorig(pnr));
ut = pvget(sys.idgrey,'Utility');
try
    x0 = ut.X0;
catch
    x0 = [];
end
if ~isempty(x0)
    
    [a,b,c,d,k,x0dum,xnrr,levnr] = procmod(sys.idgrey.par,1,sys.idgrey.file);
    xnr = [];
    for ku = uind
        if ku==1
            xnr=[xnr;[1:xnrr(ku)]'];
        else
            xnr = [xnr;[xnrr(ku-1)+1:xnrr(ku)]'];
        end
    end
    % x0=x0(xnr);
    nex = length(x0);
    switch file{3}
        case 'ARMA1'
            xnr =[xnr;nex];
        case 'ARMA2'
            xnr = [xnr;nex-1;nex];
    end
    sys.idgrey = pvset(sys.idgrey,'ParameterVector',pars,'FileArgument',file,'X0',x0(xnr));
    ut = pvget(sys.idgrey,'Utility');
    idm = uset(idm,ut);
else
    %x0 = sys.idgrey.X0;
    sys.idgrey = pvset(sys.idgrey,'ParameterVector',pars,'FileArgument',file);
end

% Also X0 in case estimated!
sys = pvset(sys,'idmodel',idm(yind,uind));
sys = pvset(sys,'PName',pnameorig(pnr), 'CovarianceMatrix',covv);

% Now fix idpoly if any:
ut = pvget(sys,'Utility');
try
    pol = ut.Idpoly;
catch
    pol = [];
end
if ~isempty(pol)
    if flagall
        covL = covlamb(L,Ncap);
    end
    k1=1;
    for kk=yind
        if isa(pol,'cell')
            polte=pol{kk}; 
        else
            polte=pol;
        end
        if flagall
            
            pol1{k1} = idpole2v(polte,L,covL,nu);
            
        elseif flagnoise%isempty(uind) 
            try
                 pol1{k1}=polte(1,nu+1:nu+ny);
            catch
                           pol1{k1} = polte('n');
                       end
        else  %this is tricky: if model is all measured inputs,
                             % you cannot deal with extra inputs being fake outputs.
            if norm(pvget(sys,'NoiseVariance'))==0
                pol1{k1}=polte(1,uind);
            else
            pol1{k1}=polte(1,[uind,nu]);%%LL was nu+yind
        end
        end
        k1=k1+1;
    end
    pol = pol1;
end
ut.Idpoly = pol;
sys = pvset(sys,'Utility',ut);
