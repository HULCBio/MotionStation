function text = display(m,conf)
%DISPLAY  display for IDPOLY objects

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $ $Date: 2004/04/10 23:16:29 $

if isempty(m)
    text = str2mat('Empty IDPOLY model.');
    if nargout == 0
        disp(text)
    end
    
    return
end
if nargin < 2
    conf = 0; % no conf
end
nu = size(m,'nu');
if conf&isreal(m)
    [a,b,c,d,f,da,db,dc,dd,df]=polydata(m);
else
    [a,b,c,d,f] = polydata(m);
    da = zeros(1,0);db=zeros(nu,0);dc=zeros(1,0);dd=zeros(1,0);df=zeros(nu,0);
end
nu = size(b,1);
Ts = pvget(m,'Ts');

% Make this easy to turn on and off ..
%display_uncertainty = 0;
%if ~display_uncertainty
%  da = da(:,[]); db = db(:,[]); dc = dc(:,[]); dd = dd(:,[]); df = df(:,[]);
%end
nv = pvget(m,'NoiseVariance');
if isempty(nv) | norm(nv) == 0
    noisetxt1 = '';
    noisetext2 = '';
    k = [];
else
    if m.nc == 0
        if m.nd == 0
            noisetext2 = ' + e(t)';
        else
            noisetext2 = ' + [1/D(q)]e(t)';
        end
    else
        if m.nd == 0
            noisetext2 = ' + C(q)e(t)';
        else
            noisetext2 = ' + [C(q)/D(q)]e(t)';
        end
    end
end

if nu>0
    switch m.na
    case 0
        if m.nf == 0
            model2 = ['y(t) = B(q)u(t)',noisetext2];
        else
            model2 = ['y(t) = [B(q)/F(q)]u(t)',noisetext2];  
        end
        
    otherwise
        if m.nf == 0  
            
            model2 = ['A(q)y(t) = B(q)u(t)',noisetext2];
        else
            model2 = ['A(q)y(t) = [B(q)/F(q)]u(t)',noisetext2];  
        end
    end
    
else
    switch m.nc
    case 0
        if m.nd == 0
            if m.na == 0
                model2 = 'y(t) = e(t)';
            else
                model2 = 'A(q)y(t) = e(t)';
            end
        else
            model2 = 'A(q)y(t) = [1/D(q)]e(t)';
        end
    otherwise
        if m.na == 0
            if m.nd == 0
                model2 = 'y(t) = C(q)e(t)';
            else
                model2 = 'y(t) = [C(q)/D(q)]e(t)';
            end
        elseif m.nd == 0
            model2 = 'A(q)y(t) = C(q)e(t)';
        else
            model2 = 'A(q)y(t) = [C(q)/D(q)]e(t)';
        end
    end
end
if Ts==0
    model1 = 'Continuous-time IDPOLY model: ';
    model2 = strrep(model2,'q','s');
    dch    = 's';
else
    model1 = 'Discrete-time IDPOLY model: ';
    dch    = 'q';
end
nchar = 60;
nl    = sprintf('\n');
txt = [model1 model2];
if m.na>0
    str=sformat(['A(',dch,') = ',poly2str(a,dch,da)],'+-',nchar);
    txt = str2mat(txt,str,' ');
    
end
if any(m.nb>0)
    if nu==1
        str=sformat(['B(',dch,') = ',poly2str(b,dch,db)],'+-',nchar);
        txt = str2mat(txt,str,' ');
    else
        b=pvget(m,'b');
        for ku = 1:nu
            str=sformat(['B',int2str(ku),'(',dch,') = ',...
                    poly2str(b(ku,:),dch,db(ku,:))],'+-',nchar);
            txt = str2mat(txt,str,' ');
        end
    end
end
if m.nc>0
    str=sformat(['C(',dch,') = ',...
            poly2str(c,dch,dc)],'+-',nchar);
    txt = str2mat(txt,str,' ');
end
if m.nd>0
    str=sformat(['D(',dch,') = ',...
            poly2str(d,dch,dd)],'+-',nchar);
    txt = str2mat(txt,str,' ');
end

if any(m.nf>0)
    if nu==1
        str=sformat(['F(',dch,') = ',...
                poly2str(f,dch,df)],'+-',nchar);
        txt = str2mat(txt,str,' ');
    else
        b=pvget(m,'f');
        for ku = 1:nu
            str=sformat(['F',int2str(ku),'(',dch,') = ',...
                    poly2str(f(ku,:),dch,df(ku,:))],'+-',nchar);
            txt = str2mat(txt,str,' ');
        end
    end
end
id = pvget(m,'InputDelay');
if any(id),
    txt = str2mat(txt,[sprintf('Input delays (listed by channel): ')...
            sprintf('%0.3g  ',id')]);
end

estim = pvget(m,'EstimationInfo');
switch lower(estim.Status(1:3))
case 'est'
    DN = estim.DataName;
    if ~isempty(DN)
        str = str2mat(sprintf('Estimated using %s from data set %s',...
            estim.Method, estim.DataName),sprintf('Loss function %g and FPE %g',...
            estim.LossFcn, estim.FPE));
    else
        str = sprintf('Estimated using %s\nLoss function %g and FPE %g',...
            estim.Method,estim.LossFcn, estim.FPE);
    end
case 'mod'
    str = sprintf('Originally estimated using %s (later modified).',...
        estim.Method);
case 'not'
    str = sprintf('This model was not estimated from data.');
case 'tra'
    str = sprintf('Model translated from the old Theta-format.');
otherwise
    str = [];
end
txt = str2mat(txt,str);

if Ts~=0,
    txt = str2mat(txt,sprintf('Sampling interval: %g %s', Ts,pvget(m,'TimeUnit')));
end
if conf
    txt=str2mat(txt,timestamp(m));
end
txt = str2mat(txt,' ');
if ~nargout
    disp(txt)
else
    text = txt;
end









