function [sys,par,Type,pnr,dnr] = considp(sys,tpflag)
%CONSIDP Checks the consistency of an IDPROC object
%
%   MODM = CONSIDP(MOD)
%
%   MODM a modified object with, when possible, corrected inconstencies

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:17:04 $

%

Kp = sys.Kp;
nu = length(Kp.status);
pp = [sys.Kp,sys.Tp1,sys.Tp2,sys.Tw,sys.Zeta,sys.Tp3,sys.Td,sys.Tz];
names = {'Kp','Tp1','Tp2','Tw','Zeta','Tp3','Td','Tz'};
%  check lengths:
[xpp{1:8}] = deal(pp.min);
%check lower limit for delay
mmd = xpp{7};
 if any(mmd<0)
    warning(sprintf(['The lower bound for the time delay must be non-negative.']))
     sys.Td.min = max(mmd,0);
     xpp{7}=max(mmd,0);
end
% check lower limits for time constants
mtes = xpp(2:6);
mtes1 = cat(1,mtes{:});
minnr = find(mtes1<=0);
if ~isempty(minnr)
    warning(sprintf(['Lower bound on time constamts must be strictly positive.',...
        '\nThey have been replaced by 0.001.']))
mtes1(minnr)=0.001;
xpp(2:6) = num2cell(mtes1,2)';

parnr = unique(rem(minnr,5));
for kpar = parnr'
    switch kpar
        case 1
            sys.Tp1.min = xpp{2};
        case 2
            sys.Tp2.min = xpp{3};
        case 3
            sys.Tw.min = xpp{4};
        case 4
            sys.Zeta.min = xpp{5};
        case 5
            sys.Tp3.min = xpp{6};
    end
end
end
lt1 = cellfun('size',xpp,2);
kp = find(lt1~=nu);
if ~isempty(kp)
    error(['The ''min'' field of ',names{kp},' should have length ',int2str(nu)])
end
lmin = cat(1,xpp{:});
[xpp{1:8}] = deal(pp.max);
lt2 = cellfun('size',xpp,2);
kp = find(lt2~=nu);
if ~isempty(kp)
    error(['The ''max'' field of ',names{kp},' should have length ',int2str(nu)])
end
lmax = cat(1,xpp{:});
[d1,d2] = find(lmax<=lmin);
if ~isempty(d1)
    if nu >1
        add = [' for input number ',int2str(d2(1))];
    else
        add = '';
    end
    error(['The ''max'' field',add,' of ',names{d1(1)},...
            ' must be strictly larger than the ''min'' field.'])
end
[Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal

procpar1 = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
procp= procpar1;
procp = max(min(procpar1,lmax),lmin);
[d1,d2] = find(isnan(procpar1));
for kd=1:length(d1)
    procp(d1(kd),d2(kd))=NaN;
end
typec = i2type(sys);
[par,Type,pnr,dnr] = parproc(procp,typec);
par = [par;dmpar];%%LL
fa = get(sys.idgrey,'file');
fa{5} = pnr;
sys.idgrey = pvset(sys.idgrey,'FileArgument',fa);
sys = pvset(sys,'ParameterVector',par);        
[xpp{1:8}] = deal(pp.status);
lt2 = cellfun('size',xpp,2);
kp = find(lt2~=nu);
if ~isempty(kp)
    error(['The ''status'' field of ',names{kp},' should have length ',int2str(nu)])
end
for ku = 1:nu
    % First fix temporaty inconsistencies when tp1/tp2 and Tw/zeta change
    % status: tpflag show when these, in this order, have been changed.
    stat = [strcmp(sys.Tp1.status{ku},'zero'),strcmp(sys.Tp2.status{ku},'zero'),...
            strcmp(sys.Tw.status{ku},'zero'),strcmp(sys.Zeta.status{ku},'zero')];
    if (stat(1)&tpflag(1))% Tp1 has been set to zero
        sys.Tp2.status{ku} = 'zero';
    end
    if (~stat(1)&tpflag(1))|(~stat(2)&tpflag(2))% Tp1 or Tp2 has been set to non-zero
        sys.Tw.status{ku} = 'zero';
        sys.Zeta.status{ku} = 'zero';
         if ~stat(2)&tpflag(2)&stat(1) % Tp2 has been set to non-zero while Tp1 is zero
            sys.Tp1.status{ku} ='est';
        end
    end
    if (~stat(3)&tpflag(3))|(~stat(4)&tpflag(4))% Tw or Zeta has been set to non-zero
        sys.Tp1.status{ku} = 'zero';
        sys.Tp2.status{ku} = 'zero';
        if ~stat(3)&tpflag(3)&stat(4) % Tw has been set to non-zero while Zeta is zero
            sys.Zeta.status{ku} ='est';
        end
        if ~stat(4)&tpflag(4)&stat(3) % Zeta has been set to non-zero while Tw is zero
            sys.Tw.status{ku} ='est';
        end
    end
    % If one of Tw or Zeta is zero so must the other be:
    if strcmp(sys.Tw.status{ku},'zero')|strcmp(sys.Zeta.status{ku},'zero')
        sys.Tw.status{ku}='zero';
        sys.Zeta.status{ku}='zero';
    end
    if ~strcmp(sys.Tw.status{ku},'zero')|~strcmp(sys.Zeta.status{ku},'zero')
        
        sys.Tp1.status{ku} = 'zero';
        sys.Tp2.status{ku} = 'zero';
        if strcmp(sys.Zeta.status{ku},'zero')
            sys.Zeta.status{ku} = 'estimate';
        end
        if strcmp(sys.Tw.status{ku},'zero')
            sys.Tw.status{ku} = 'estimate';
        end
    end
    if strcmp(sys.Tp1.status{ku},'zero')&strcmp(sys.Tw.status{ku},'zero')
        sys.Tp2.status{ku} = 'zero';
        sys.Tz.status{ku} = 'zero';
             sys.Tp3.status{ku} = 'zero';
           
    end
    if strcmp(sys.Tp2.status{ku},'zero')&strcmp(sys.Tw.status{ku},'zero')
        sys.Tp3.status{ku} = 'zero';
    end
end