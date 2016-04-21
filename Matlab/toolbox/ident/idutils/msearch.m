function [Vnew,parnew,stop,delta,lambda,tlam]=...
    msearch(V,z,par,struc,psi,e,delta,algorithm,lambdaold,tlamold,dispmode)
%MSEARCH   Searches for a lower value of the criterion function
%
%	[TH,ST] = msearch(Z,TH,G,LIM)
%
%	TH : New parameter giving a lower value of the criterion
%	ST=1 : No lower value of the criterion could be found.
%
%	The routine evaluates the prediction error criterion at values
%	along the G-direction, starting at TH. It is primarily intended
%	as a subroutine to MINLOOP. See PEM for an explanation of the
%	arguments.

%	L. Ljung 10-1-86,9-25-93
%	Copyright 1986-2002 The MathWorks, Inc.
%	$Revision: 1.13.4.1 $ $Date: 2004/04/10 23:18:41 $

% *** Set up the model orders ***

try
    dflag = struc.dflag;
catch
    dflag = 0;
end
npar=length(par); 
update=zeros(npar,1); 
ind3 = algorithm.estindex;
% *** Looping, attempting to find a lower value of V along
%     the G-direction ***

pinvtol = algorithm.Advanced.Search.GnsPinvTol;
maxbis = algorithm.Advanced.Search.MaxBisections;
lmstep = algorithm.Advanced.Search.LmStep;
stepred = algorithm.Advanced.Search.StepReduction;
relimp = algorithm.Advanced.Search.RelImprovement;
direc = lower(algorithm.SearchDirection);
if strcmp(direc,'auto')
    direc = {'gns','lm','grad'};
elseif any(strcmp(direc,{'gns','gn'}))
    direc = {direc,'grad'};
else
    direc = {direc};
end
stop = 1;
for kdir = direc
    if ~stop,break,end
    kdir = kdir{1};
    l=0;
    stop = 0;
    if dispmode,disp(['   Search direction: ',kdir]),end
    switch kdir   
    case 'lm' % levenberg-marquard
        gdir = pinv(psi,pinvtol)*e; 
        delta = delta/lmstep/2;
    case 'gns'
        gdir = pinv(psi,pinvtol)*e;
    case 'gn'
        gdir = psi\e;
    case 'grad'
        gdir = psi'*e*npar/norm(psi);
    end
    if strcmp(struc.type,'ssfree')
        update=gdir;par=zeros(size(gdir));npar=length(par); 
    else
        update(ind3) = gdir;
    end
    parnew = par+update;
    if isfield(struc,'bounds')
        bounds = struc.bounds;
            parnew(bounds(:,1)) = min(max(parnew(bounds(:,1)),bounds(:,2)),bounds(:,3));
        end
%     if any(dflag) 
%         parnew(dflag)=min(max(0,parnew(dflag)),50*struc.modT);  
%     end
    [lambda,tlam] = gnnew(z,parnew,struc,algorithm);
    
    Vnew=real(det(lambda));
    if Vnew<0,Vnew=inf;end
    while ((Vnew - V) > -V*relimp)& l<maxbis
        switch kdir
            case 'lm'
            if l>0
                delta = delta*lmstep;
            end
            
            if strcmp(struc.type,'ssfree')
                update = pinv([psi;delta*eye(npar)])*[e;zeros(npar,1)];
            else
                update(ind3) = pinv([psi;delta*eye(length(ind3))])*[e;zeros(length(ind3),1)];
            end
        case {'gns','gn','grad'}
            update = update/stepred;
        end
        parnew = par+update;
         if isfield(struc,'bounds')
        bounds = struc.bounds;
            parnew(bounds(:,1)) = min(max(parnew(bounds(:,1)),bounds(:,2)),bounds(:,3));
        end
%         if dflag 
%             parnew(dflag)=min(max(0,parnew(dflag)),20*struc.modT);
%         end
        [lambda,tlam] = gnnew(z,parnew,struc,algorithm);
        Vnew=real(det(lambda));
        if Vnew<=0,Vnew=inf;end
        
        l = l+1;
        if l==maxbis, stop = 1;end
    end
end % kdir

if dispmode  % Give status information to the screen
    disp(['   Bisected search vector ',int2str(l),' times']),
end
if stop,parnew=par;Vnew=V;lambda=lambdaold;tlam=tlamold;end






