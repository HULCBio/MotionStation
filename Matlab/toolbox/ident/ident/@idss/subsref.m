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
%   MOD('measured') selects just the measured input channels and 
%       ignores the noise inputs.
%   MOD('noise') gives a time series (no measured input channels)
%       description of the additive noise properties of MOD.
%
%   To jointly address measured and noise channels, first convert
%   the noise channels using NOISECNV.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.27.4.1 $ $Date: 2004/04/10 23:18:15 $ 

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
            result = indexref(sys,Struct(1).subs);
            
            if ~(isempty(pvget(sys,'PName'))&isempty(pvget(sys,'FixedParameter')))
            try
                result = fixnames(result,sys,Struct(1).subs);
            catch
                result = pvset(result,'PName',{},'FixedParameter',[]);
            end
            end
        else
            result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
        end
    catch
        error(lasterr)
    end
    
otherwise
    error(['Unsupported type ' Struct(1).type])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,index)
if isempty(sys)
    return 
end

try
    [yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
        subndeco(sys.idmodel,index,pvget(sys,'NoiseVariance'));
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
        sys = idss;
    elseif returnflag ==3
        sys = [];
    end
    return
end
[a,b,c,d,k,x0]=ssdata(sys);
[ny,nu]=size(d);nx=size(a,1);
par=pvget(sys,'ParameterVector');
npar = length(par);
sys1=parset(sys,[1:npar]');
[a1,b1,c1,d1,k1,x01]=ssdata(sys1);
nk=pvget(sys,'nk');

if strcmp(sys.SSParameterization,'Canonical')
    sys.SSParameterization='Structured'; 
end
if strcmp(sys.SSParameterization,'Structured')
    cov = pvget(sys.idmodel,'CovarianceMatrix');
    if ischar(cov), cov = [];end
end
ssporig = sys.SSParameterization;
As = sys.As; Bs = sys.Bs; Cs = sys.Cs;
Ds = sys.Ds; Ks = sys.Ks; X0s = sys.X0s;
if flagall
    L = chol(pvget(sys.idmodel,'NoiseVariance'));
    idm = sys.idmodel;
    try
        ei = pvget(idm,'EstimationInfo');
        Ncap = ei.DataLength;
        if isempty(Ncap)
            Ncap = inf;
        end
    catch
        Ncap = inf;
    end
    L = L'; % is now lower triangular
    nl = ny*(ny+1)/2; % No of pars in L
    % the cholesky factor is such that e = L*v with v unit covariance
    b = [b k*L];
    num = npar+1;
    d12 = zeros(ny,ny);
    for ky=1:ny
        for ku=1:ky
            d12(ky,ku) = num;
            num = num+1;
        end
    end
    k12 = zeros(nx,ny);
    for kx = 1:nx
        for ky = 1:ny
            k12(kx,ky) = num;
            num = num + 1;
        end
    end
    b1 =[b1 k12];
    % Now the derivative of K*L wrt L and K
    if strcmp(sys.SSParameterization,'Structured')
        if ~isempty(cov)
            Pl = covlamb(L,Ncap); 
            cov = [[cov,zeros(npar,nl)];[zeros(nl,npar),Pl]]; % extended with
            % the covariance of L
            nr1 = sum(sum(isnan([As,Bs,[Cs]']))')+sum(sum(isnan(sys.Ds))'); 
            nr2 = sum(sum(isnan(Ks))');
            trf=zeros(nx*ny,(ny*(ny+1)/2+npar));
            s=npar+1;
            for ky=1:ny % der wrt l
                for ku=1:ky
                    lz =zeros(ny,ny);
                    lz(ky,ku)=1;
                    dk = (k*lz)';
                    trf(:,s)=dk(:);
                    s=s+1;
                end
            end
            s = nr1+1;
            for kx=1:nx
                for ky=1:ny
                    if isnan(Ks(kx,ky))
                        tk = zeros(nx,ny);tk(kx,ky)=1;
                        dk = (tk*L)';
                        trf(:,s)= dk(:);
                        s = s+1;
                    end
                end
            end
            cov = [[cov cov*trf'];[trf*cov trf*cov*trf']];   
        end
    end
    d = [d L]; d1=[d1 d12];
    Bs = [Bs NaN*ones(size(k))];
    Ds = [Ds triu(NaN*ones(ny,ny))'];
    nk = [nk zeros(1,ny)];
    lam = zeros(ny,ny);
    k = zeros(size(k)); k1 = k;
    Ks = k;
    uind = [1:ny+nu];
elseif flagmea
    k = zeros(size(k)); k1 = k;
    Ks = k;
    lam = zeros(ny,ny);
end

b = b(:,uind); Bs = Bs(:,uind); b1 = b1(:,uind);
c = c(yind,:); Cs = Cs(yind,:); c1 = c1(yind,:);
d = d(yind,uind); Ds = Ds(yind,uind); d1 = d1(yind,uind);
k = k(:,yind);  Ks = Ks(:,yind); k1 = k1(:,yind);
nk = nk(uind);
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
    sys.idmodel = pvset(sys.idmodel,'NoiseVariance',lam);
end
sys.idmodel=sys.idmodel(yind,uind);
if strcmp(sys.SSParameterization,'Structured')
    sys=pvset(sys,'B',b,'C',c,'D',d,'K',k,'Bs',Bs,'Cs',Cs,'Ds',Ds,'Ks',Ks);
    parnew = findnan({a1,b1,c1,d1,k1,x01},{sys.As,Bs,Cs,Ds,Ks,sys.X0s});
    if length(cov)>=max(parnew)
        sys = pvset(sys,'CovarianceMatrix',cov(parnew,parnew));
    end
else
    sys=pvset(sys,'B',b,'C',c,'D',d,'K',k,'Ks',Ks,'Bs',Bs,'Cs',Cs,'Ds',Ds);
end
if strcmp(ssporig,'Free')&(flagall|flagmea|flagnoise)
    sys = pvset(sys,'SSParameterization','Free');
end

ut = pvget(sys,'Utility');
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
        Pmod = subsref(Pmod,stru);
    else
        stru.subs = {yind,uind};
        Pmod = subsref(Pmod,stru);
    end
end

ut.Pmodel = Pmod;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    fixn =[];
    for kk= 1:length(fix)
        ff = find(fix(kk)==pp);
        if ~isempty(ff)
            fixn(kc) = ff; 
            kc = kc+1;
        end
    end
    result = pvset(result,'FixedParameter',fixn);
end



    