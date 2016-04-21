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


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.1 $ $Date: 2004/04/10 23:18:01 $

function result = subsref(sys,Struct)

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
                    end % Could fail in 'allx9' case
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = indexref(sys,index)
if isempty(sys)
    return 
end
lam = pvget(sys.idmodel,'NoiseVariance');
lam1 = lam;
ts = pvget(sys,'Ts');
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
        sys = idpoly;
    elseif returnflag ==3
        sys = [];
    end
    return
end

[a,b,c,d,f]=polydata(sys);
nb=size(b,2);nf=size(f,2);nc=size(c,2);nd=size(d,2);
[nu]=size(b,1); ny=1;
if flagall
    if ts>0
        b=[[b,zeros(nu,nc-nb)];[ sqrt(lam)*c,zeros(1,nb-nc)]]; 
        f=[[f,zeros(nu,nd-nf)];[d,zeros(1,nf-nd)]];
    else
        b=[[zeros(nu,nc-nb),b];[zeros(1,nb-nc), sqrt(lam)*c]]; 
        f=[[zeros(nu,nd-nf),f];[zeros(1,nf-nd),d]];
    end
    lam = 0;c1=c;
    c=1;d=1;
elseif flagmea
    c=1;d=1; lam = 0;
elseif isempty(uind)
    b=[];f=[];
else
    b=b(uind,:); f= f(uind,:);
end

na=sys.na;nb=sys.nb;nc=sys.nc;nd=sys.nd;nf=sys.nf;
covm=pvget(sys.idmodel,'CovarianceMatrix'); 
if ischar(covm)
    covnone = 1;
else
    covnone = 0;
end
if flagall
    in = pvget(sys.idmodel,'InputName');
    ut = pvget(sys.idmodel,'OutputName');
    pre = noiprefi('v');
    for ky = 1:ny
        in =[in;{[pre,ut{ky}]}];
    end
    
    sys.idmodel = pvset(sys.idmodel,'InputName',in);%[in;defnum({},'e',ny)']);%{'e1';'e2';'e3'}]);
    iu = pvget(sys.idmodel,'InputUnit');
    sys.idmodel = pvset(sys.idmodel,'InputUnit',[iu; ...
            pvget(sys.idmodel,'OutputUnit')]); 
    sys.idmodel = pvset(sys.idmodel,'InputDelay', ...
        [pvget(sys.idmodel,'InputDelay');0]);
else
    sys.idmodel=sys.idmodel(yind,uind);
end

sys=pvset(sys,'b',b,'c',c,'d',d,'f',f,'NoiseVariance',lam); 
if covnone
    sys = pvset(sys,'CovarianceMatrix','None');
end

if ~(isempty(covm)|ischar(covm))
    
    Nb=[0,cumsum(nb)];Nf=[0,cumsum(nf)];indb=[];indf=[];
    for ku=uind
        indb=[indb,Nb(ku)+1:Nb(ku+1)];
        indf=[indf,Nf(ku)+1:Nf(ku+1)];
    end
    if flagall
        np = size(covm,1);
        es = pvget(sys.idmodel,'EstimationInfo');
        try
            Ncap = es.DataLength;
        catch
            Ncap = [];
        end
        if isempty(Ncap),Ncap =inf;end
        nab = na+sum(nb);
        nabc = nab+nc+1;
        covm =[[covm,zeros(np,1)];[zeros(1,np),lam1/2/Ncap]]; % adding the variance of Lambda
        ind1 = [1:nab,np+1,nab+1:np];
        cocmll=covm;
        covm = covm(ind1,ind1); % Placing lam right before C
        trfm = eye(np+1);
        trfm(nab+1,nab+1:nabc)=c1; % der wrt lam
        trfm(nab+2:nabc,nab+2:nabc)=sqrt(lam1)*eye(nc);
        %trfm(:,np+1)=c1.';
        %trfm(2:end,na+sum(nb)+1:na+sum(nb)+nc)=eye(nc)*sqrt(lam1);
        covm = trfm'*covm*trfm;%[[covm,covm*trfm'];[trfm*covm,trfm*covm*trfm']];
        parind = [1:nabc,nabc+nd+1:np+1,nabc+1:nabc+nd];%np+2:np+nc+2,...
        %na+sum(nb)+sys.nc+sys.nd:np,na+sum(nb)+sys.nc+1:na+sum(nb)+sys.nc+sys.nd];
    else
        parind=[1:na,na+indb,na+sum(nb)+1:na+sum(nb)+sys.nc+sys.nd,na+sum(nb)+nc+nd+indf];
    end
    if length(parind)~=length(pvget(sys.idmodel,'ParameterVector'))
        warning('Covariance information not updated.')
        covv = [];
    else
        covv = covm(parind,parind);
    end
    sys.idmodel=pvset(sys.idmodel,'CovarianceMatrix',covv);
end


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
    fixn = [];
    for kk= 1:length(fix)
        ff = find(fix(kk)==pp);
        if ~isempty(ff)
            fixn(kc) = ff; 
            kc = kc+1;
        end
    end
    result = pvset(result,'FixedParameter',fixn);
end

