function result = subsref(sys,Struct)
%SUBSREF  Subsref method for IDMODEL models
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
%     

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.20.4.1 $ $Date: 2004/04/10 23:16:14 $

StrucL = length(Struct);

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
            [result,fixflag] = indexref(sys,Struct(1).subs,inputname(1));
            if ~(isempty(pvget(sys,'PName'))&isempty(pvget(sys,'FixedParameter')))
                if fixflag
                    warning('PNames and/or FixedParameter has been lost by this transformation.')
                    result = pvset(result,'PName',{},'FixedParameter',[]);
                else
                    try
                        result = fixnames(result,sys,Struct(1).subs);
                    catch
                        result = pvset(result,'PName',{},'FixedParameter',[]);
                    end % Could fail in 'allx9' case            
                end
            end
        else
            result = subsref(indexref(sys,Struct(1).subs),Struct(2:end),inputname(1));
        end
    catch
        error(lasterr)
    end
    
otherwise
    error(['Unsupported type ' Struct(1).type])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,fixflag] = indexref(sys,index,nam)

fixflag = 0;
if isempty(sys)
    return 
end 
[A,B]=arxdata(sys);
ny = size(A,1);
nu=size(B,2);
lam = pvget(sys.idmodel,'NoiseVariance');
try
    [yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
        subndeco(sys.idmodel,index,lam);
catch
    error(lasterr)
end
if flagnoise
    sys = tsflag(sys,'set');
end
if flagboth
    sys = setnoime(sys);
    return
end 
if returnflag
    if returnflag==2
        sys = idarx;
    elseif returnflag ==3
        sys = [];
    end
    return
end
try
    err = ~(all(yind==[1:ny]));
catch
    err = 1;
end
if norm(sys.na)==0
    err = 0;
end
if err
    sys=idss(sys);
    sys = sys(yind,uind);
    fixflag = 1;
    return
end 
if flagall
    in = pvget(sys.idmodel,'InputName');
    ut = pvget(sys.idmodel,'OutputName');
    pre = noiprefi('v');
    for ky = 1:ny
        in =[in;{[pre,ut{ky}]}];
    end
    
    sys.idmodel = pvset(sys.idmodel,'InputName',in); 
    iu = pvget(sys.idmodel,'InputUnit');
    sys.idmodel = pvset(sys.idmodel,'InputUnit',[iu; ...
            pvget(sys.idmodel,'OutputUnit')]); 
    sys.idmodel = pvset(sys.idmodel,'InputDelay', ...
        [pvget(sys.idmodel,'InputDelay');zeros(ny,1)]);
end
if flagall|flagmea
    sys.idmodel = pvset(sys.idmodel,'NoiseVariance',zeros(ny,ny));
end
if flagall
    cov = pvget(sys.idmodel,'CovarianceMatrix');
    if isempty(cov)
        calcov = 0;
    else
        calcov = 1;
    end
    
    clam = chol(lam).';
    B(:,nu+1:nu+ny,1)=clam;
    if calcov
        npar = length(cov);
        sys1=parset(sys,[1:npar]');
        es = pvget(sys,'EstimationInfo');
        try
            Ncap = es.DataLength;
            if isempty(Ncap), Ncap = inf;end
        catch
            Ncap =inf;
        end
        
        [A1,B1]=arxdata(sys1);
        s = npar+1;
        for ky1=1:ny
            for ky2=1:ky1
                if clam(ky1,ky2)~=0, 
                    dm(ky1,ky2)=s; 
                    s=s+1;
                end
            end
        end
        B1(:,nu+1:nu+ny,1) = dm;
        sys1=pvset(sys1,'B',B1);
        sys = pvset(sys,'B',B);
        
        
        Plam = covlamb(lam,Ncap); 
        nl = size(Plam,1);
        
        cov = [[cov,zeros(npar,nl)];[zeros(nl,npar),Plam]];
        par1 = pvget(sys1.idmodel,'ParameterVector');
        sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',cov(par1,par1));
    else
        sys = pvset(sys,'B',B);
    end
elseif flagmea
    sys.idmodel=sys.idmodel(yind,uind);
else
    par=pvget(sys,'ParameterVector');
    npar = length(par);
    cov = pvget(sys.idmodel,'CovarianceMatrix');
    if ischar(cov), cov1 =[];else cov1=cov;end
    sys0=sys;
    sys.idmodel=sys.idmodel(yind,uind);
    if ~isempty(cov1)
        sys1=parset(sys0,[1:npar]');
        [A1,B1]=arxdata(sys1);
        sys1.idmodel=sys1.idmodel(yind,uind);
        sys1=pvset(sys1,'B',B1(yind,uind,:),'A',A1(yind,yind,:));
        par1 = pvget(sys1,'ParameterVector');
        cov = cov1(par1,par1);
    end
    sys=pvset(sys,'B',B(yind,uind,:),'A',A(yind,yind,:)); 
    sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',cov); 
end
%%%%%%%%
% Now the hidden models
ut=pvget(sys,'Utility'); 
if isaimp(sys)
    imp.B = ut.impulse.B(yind,uind,:);
    imp.dB = ut.impulse.dB(yind,uind,:);
    imp.dBstep = ut.impulse.dBstep(yind,uind,:);
    imp.time = ut.impulse.time;
    ut.impulse = imp;
end
try
    pol=ut.Idpoly;  
catch
    pol=[];
end
try
    Pmod = ut.Pmodel;
catch
    Pmod = [];
end
if ~isempty(Pmod)
    stru.type='()';
    if flagall
        stru.subs={':','allx9'};
        Pmod = subsref(Pmod,stru);%(:,'all');
    else
        stru.subs = {yind,uind};
        Pmod = subsref(Pmod,stru);%(yind,uind);
    end
end

ut.Pmodel = Pmod;
if ~isempty(pol)
    k1=1;
    for kk=yind
        if isa(pol,'cell')
            polte=pol{kk}; 
        else
            polte=pol;
        end
        if flagall
            pol1{k1}=polte;
        elseif isempty(uind)
            pol1{k1}=polte(1,nu+1:nu+ny);  
        else
            pol1{k1}=polte(1,uind);
        end
        k1=k1+1;
    end
    pol = pol1;
end
ut.Idpoly=pol;
sys=pvset(sys,'Utility',ut);


%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function result = fixnames(result,sys,ind)
par = pvget(sys,'ParameterVector');
parc = [1:length(par)]';
sys1=pvset(sys,'ParameterVector',parc,'CovarianceMatrix',[]);
sys1 = indexref(sys1,ind);
pp = pvget(sys1,'ParameterVector');
newi = zeros(length(pp),1);
for kk = 1:length(pp)
    newi(kk) = find(pp(kk)==parc);
end

nam1 = pvget(sys,'PName');
if ~isempty(nam1)
    result = pvset(result,'PName',nam1(newi));
end
fix = pvget(sys,'FixedParameter');
if ~isempty(fix)&isa(fix,'double');
    kc = 1;
    fixn=[];
    for kk= 1:length(fix)
        ff = find(fix(kk)==pp);
        if ~isempty(ff)
            fixn(kc) = ff; 
            kc = kc+1;
        end
    end
    result = pvset(result,'FixedParameter',fixn);
end

