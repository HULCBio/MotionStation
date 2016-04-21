function thd=c2daux(thc,T,method)
%IDSS/C2DAUX  Help functionto IDMODEL/C2D    

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/10 23:17:53 $

if nargin < 2
   disp('Usage: SYSD = C2D(SYSC,Ts)')
   disp('       SYSD = C2D(SYSC,Ts,METHOD)')
   disp('       METHOD is one of ''Zoh'' or ''Foh''')
   return
end
if nargin < 3
   method = 'Zoh';
end

Told=pvget(thc.idmodel,'Ts'); 
if Told>0,error('This model is already  discrete-time!'),end
if T<=0,error('The sampling interval must be positive!'),end
lamscale=1/T; 
[ny,nu]=size(thc);
p = pvget(thc.idmodel,'ParameterVector');
covp = pvget(thc.idmodel,'CovarianceMatrix');
lam = pvget(thc.idmodel,'NoiseVariance');
inpd = pvget(thc.idmodel,'InputDelay');
dfrac = inpd-floor(inpd/T);
dfrac=dfrac(:).';
if abs(dfrac)<10e4*eps
    dfrac=zeros(1,nu);
end
inpd = floor(inpd/T); 
utflag = 0;
if  strcmp(thc.SSParameterization,'Free')
    % In this case Pmodel has no value, since it will loose its
    % covarianceinformation. Instead create Idpoly, if neccessary,
    % unless covariance = 'none'
    setcov(thc);
    ut = pvget(thc,'Utility');
    utflag = 1;
    try
        ut.Pmodel = [];
        thc = pvset(thc,'Utility',ut);
    end
end
[A,B,C,D,K,X0]=ssdata(thc); 
[A,B,Cc,D,K,Ls] = idsample(A,B,C,D,K,T,method(1),1,dfrac);
 thd = pvset(thc,'SSParameterization','Free');
if norm(D)>0
    thd=pvset(thd,'Ds',NaN*ones(size(D)));
end
if length(X0)<length(A)
    X0=[X0;zeros(length(A)-length(X0),1)];%%
end
 thd=pvset(thd,'A',A,'B',B,'C',Cc,'D',D,'K',K,'X0',X0,'NoiseVariance',lamscale*Ls*lam*Ls',...
   'Ts',T,'CovarianceMatrix',[],... 
   'InputDelay',inpd);
 if utflag,
    thd = uset(thd,ut);
end
if strcmp(thc.SSParameterization,'Canonical')
    try
    thd = pvset(thd,'SSParameterization','Canonical');
catch
    warning('Transformation back to canonical form failed.')
end
end

%%%% Now for the hidden models

thd = sethidmo(thd,'c2d',T,method);

 