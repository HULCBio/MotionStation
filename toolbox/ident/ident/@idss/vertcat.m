function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDSS models.
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
% 
%   This operation amounts to appending  the outputs of the 
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
% 
%   See also HORZCAT.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/10 23:18:16 $


ni = nargin;
if ni==1
    sys = varargin{1};
    return
end

for i = 1:ni,
    sizes = size(varargin{i});
end
nsys = length(varargin);
if nsys==0,
    sys = idss;  return
end

% Initialize output SYS to first input system
sys = idss(varargin{1});
for j = 2:nsys,
    [A,B,C,D,K,X0] = ssdata(sys);
    As = sys.As; Bs = sys.Bs ; Cs = sys.Cs;
    Ds = sys.Ds; Ks = sys.Ks; X0s = sys.X0s;
    P = pvget(sys.idmodel,'CovarianceMatrix');
    Lam = pvget(sys.idmodel,'NoiseVariance');
    if isempty(P)|isstr(P)
        noP = 1;
    else 
        noP = 0;
    end
    if ~noP
        par = pvget(sys.idmodel,'ParameterVector');
        l2 = length(par);
        sys1 = parset(sys,[1:l2]');
        [A1,B1,C1,D1,K1,X01] = ssdata(sys1); %% This is for tracking elements
        %% in the covariance matrix
    end
    %% Hidden models:
    ut=pvget(sys,'Utility'); 
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
    if isempty(Pmod)
        pmodel = 0;
    else
        pmodel = 1;
    end
    if isempty(pol)
        poly = 0;
    else 
        poly = 1;
    end
    
    % Concatenate remaining input systems
    sysj = idss(varargin{j});
    [a,b,c,d,k,x0] = ssdata(sysj);
    
    % Check dimension compatibility
    sizes = size(D);
    sj = size(d);
    if sj(2)~=sizes(2),
        error('In [SYS1 ; SYS2], SYS1 and SYS2 must have the same number of inputs.')
    elseif length(sj)>2 & length(sizes)>2 & ~isequal(sj(3:end),sizes(3:end)),
        error('In [SYS1 ; SYS2], arrays SYS1 and SYS2 must have compatible dimensions.')
    end
    
    try 
        sys.idmodel = [sys.idmodel ; sysj.idmodel];
    catch
        error(lasterr)
    end
    
    % Perfom concatenation
    nx = size(A,1); ny =size(C,1);
    A = [[A,zeros(nx,size(a,2))];[zeros(size(a,1),nx),a]];
    B = [B;b]; 
    C = [[C,zeros(ny,size(c,2))];[zeros(size(c,1),nx),c]]; 
    D = [D;d];
    K = [[K,zeros(nx,size(k,2))];[zeros(size(k,1),ny),k]];
    X0 = [X0;x0];
    
    As = [[As,zeros(nx,size(a,2))];[zeros(size(a,1),nx),sysj.As]];
    Bs = [Bs;sysj.Bs]; 
    Cs = [[Cs,zeros(ny,size(c,2))];[zeros(size(c,1),nx),sysj.Cs]];
    Ds = [Ds;sysj.Ds];
    Ks = [[Ks,zeros(nx,size(k,2))];[zeros(size(k,1),ny),sysj.Ks]]; 
    X0s = [X0s;sysj.X0s];
    lamj = pvget(sysj,'NoiseVariance');
    Lam = [[Lam,zeros(size(Lam,1),size(lamj,2))];[zeros(size(lamj,1),size(Lam,2)),lamj]];
    if ~noP
        Pj = pvget(sysj.idmodel,'CovarianceMatrix');
        if isempty(Pj)|isstr(Pj)
            noP = 1;
        else
            P = [[P,zeros(size(P,1),size(Pj,2))];[zeros(size(Pj,1),size(P,2)),Pj]];
            parj = pvget(sysj.idmodel,'ParameterVector');
            l1 = l2 + 1;
            l2 = l1 + length(parj);
            sysj1 = parset(sysj,[l1:l2]');
            [a1,b1,c1,d1,k1,x01] = ssdata(sysj1);
            A1 = [[A1,zeros(nx,size(a,2))];[zeros(size(a,1),nx),a1]];
            B1 = [B1;b1]; 
            C1 = [[C1,zeros(ny,size(c,2))];[zeros(size(c,1),nx),c1]]; 
            D1 = [D1;d1];
            K1 = [[K1,zeros(nx,size(k,2))];[zeros(size(k,1),ny),k1]];
            X01 = [X01;x01];
        end
    end
    %% Hidden models
    utj = pvget(sysj,'Utility');%gsutil(sysj,0,'g');
    if pmodel
        try
            Pmodj = utj.Pmodel;
        catch
            Pmodj =[];
        end
        if isempty(Pmodj)
            pmodel = 0;
        else
            was = warning;
            warning('off')
            Pmod = vertcat(Pmod,Pmodj);
            warning(was);
        end
    end
    if poly
        try
            polj = utj.Idpoly;
        catch
            polj =[];
        end
        if isempty(polj)
            poly = 0;
        else
            pol = [pol,polj];
        end
    end
    
    % Create result
    stnclash = 0;
    stn = sys.StateName;
    for ks = 1:length(sysj.StateName)
        if any(strcmp(sys.StateName,sysj.StateName{ks}))
            stnclash = 1;
        end
    end
    [newpnames,pflag,fixn] = fixnames(sys,sysj);
    sys = pvset(sys,'A',A,'B',B,'C',C,'D',D,'K',K,'X0',X0,...
        'As',As,'Bs',Bs,'Cs',Cs,'Ds',Ds,'Ks',Ks,'X0s',X0s,'NoiseVariance',...
        Lam);
    if stnclash
        warning('IDENT:Message','State Names have been modified due to name clashes.')
    else
        sys.StateName = [stn;sysj.StateName];
    end
    if pflag == 1
        warning('IDENT:Message','All systems do not have defined PNames. PNames have been set to {}.')
    elseif pflag ==2
        warning('IDENT:Message','Clash in PNames. PNames have been set to {}.')
    end
    sys = pvset(sys,'PName',newpnames,'FixedParameter',fixn);
    cov =[];
    if ~noP
        sys1 = pvset(sys,'A',A1,'B',B1,'C',C1,'D',D1,'K',K1,'X0',X01);
        par = pvget(sys1.idmodel,'ParameterVector');
        if length(P)>=max(par)
            cov = P(par,par);
        end
    end
    sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',cov);
    % Extra models:
    
    ut=pvget(sys,'Utility'); 
    if poly
        ut.Idpoly = pol;
    end
    if pmodel
        ut.Pmodel = Pmod;
    end
    sys = pvset(sys,'Utility',ut); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result,pflag,fixn] = fixnames(sys,sysj)
pflag =  0; fixn =[];
if (isempty(pvget(sys,'PName'))&isempty(pvget(sysj,'PName')))&...
        (isempty(pvget(sys,'FixedParameter'))&isempty(pvget(sysj,'FixedParameter')))
    result = {};
    return
end

if isempty(pvget(sys,'PName'))|isempty(pvget(sysj,'PName'))
    result = {};
    pflag = 1;
    
else
    pnaclash = 0;
    pna = pvget(sys,'PName');
    pnaj = pvget(sysj,'PName');
    for ks = 1:length(pnaj)
        if any(strcmp(pna,pnaj{ks}))
            pnaclash = 1;
        end
    end
    if pnaclash
        result = {};
        pflag = 2;
        
        
    end
end
par = pvget(sys,'ParameterVector');
parc = [1:length(par)]';
parj = pvget(sysj,'ParameterVector');
parcj = [length(par)+1:length(par)+length(parj)]';
sys1=pvset(sys,'ParameterVector',parc,'CovarianceMatrix',[],'PName',{},...
    'FixedParameter',[]);
sysj1=pvset(sysj,'ParameterVector',parcj,'CovarianceMatrix',[],'PName',{},...
    'FixedParameter',[]);
was = warning;
warning('off')
sys1 = horzcat(sys1,sysj1);
warning(was)
pp = pvget(sys1,'ParameterVector');
if ~pflag
newi = zeros(length(pp),1);
for kk = 1:length(pp)
    newi(kk) = find(pp(kk)==[parc;parcj]);
end

nam1 = [pvget(sys,'PName');pvget(sysj,'PName')];
if ~isempty(nam1)
    result = nam1(newi);%pvset(result,'PName',nam1(newi));
end
end
%% Now for the fixed parameters
fix = pvget(sys,'FixedParameter');
fixj = pvget(sysj,'FixedParameter');
if isa(fix,'char'),fix={fix};end
if isa(fixj,'char'),fixj={fixj};end
if isempty(fix),fix=[];end
if isempty(fixj),fixj = [];end
if (isa(fix,'cell')|isempty(fix))&(isa(fixj,'cell')|isempty(fixj))
    if pflag
        warning('IDENT:Message',...
            'PName has been lost, so FixedParameter as a cell array of PNames is also lost.')
    fixn = [];    
else
    fixn = {fix;fixj};
end
elseif (isa(fix,'double')&isa(fixj,'double'))
    fix = [fix(:);fixj(:)+length(pvget(sys,'ParameterVector'))];
    if ~isempty(fix)
        kc = 1;
        fixn = [];
        for kk= 1:length(fix)
            ff = find(fix(kk)==pp);
            if ~isempty(ff)
                fixn(kc) = ff; 
                kc = kc+1;
            end
        end
        %result = pvset(result,'FixedParameter',fixn);
    end
else%if xor(~isempty(fix)&isa(fix,'cell'),~isempty(fixj)&isa(fixj,'cell'))
    warning('IDENT:Message',...
        sprintf(['Mixing FixedParameters as integers and strings cannot',...
            ' be handled.\nFixedParameter set to [].']))
    fixn = [];
end