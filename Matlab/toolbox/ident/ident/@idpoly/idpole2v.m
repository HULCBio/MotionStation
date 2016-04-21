function polb = idpole2v(pol,L,covL,nu)
% IDPOLE2V Help function to idpolget
%    Converts an idpoly model with nu measured inputs and remaining
%    unnormalized noise inputs ('e') to one with normalized noise
%    inputs ('v')

%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:16:31 $
%   Copyright 1986-2003 The MathWorks, Inc.

% works for ARMAX but not BJ,OE etc. POL should really have C=D=1, since
% all noise channels (nu+1:end) should hav been converted to inputs

parold = pvget(pol,'ParameterVector');
npold = length(parold);
covold = pvget(pol,'CovarianceMatrix');
if isempty(covold)|ischar(covold)
    covP = 0;
else
    covP = 1;
end
nb = pol.nb;
na = pol.na;
nf = pol.nf;
nue = length(nb); 
nc = nb(nu+1:end);
nk = pol.nk;
nck = nk(nu+1:end);
npar1 = na+sum(nb(1:nu));%+sum(nf(1:nu));
npar = npar1; npar2 = npar;
npold = na+sum(nb);
addpar = 0;
outnr = find(nck==0); % this will be the output number of the idpoly
for kc = 1:length(nc) 
    if nck(kc)==1 % then we need to extend the par vactor with a zero
        parold = [parold(1:npar);0;parold(npar+1:end)];
        if covP
            covold = [[covold(1:npar,1:npar),zeros(npar,1),covold(1:npar,npar+1:end)];...
                    zeros(1,length(covold)+1);...
                    [covold(npar+1:end,1:npar),zeros(length(covold)-npar,1),...
                        covold(npar+1:end,npar+1:end)]];
        end
        nc(kc) = nc(kc)+1;nck(kc) = 0;
        addpar = addpar + 1;
    end
    npar = npar + nc(kc);
end
trf = zeros(npold+addpar,npold+addpar);
dlnewpar = zeros(npold+addpar,size(covL,1));
trf(1:npar1,1:npar1) = eye(npar1); % The a and b-part; not touched.
indco = triu(ones(length(nc),length(nc))); 
indco = reshape(cumsum(indco(:)),length(nc),length(nc))';
 
for kc = 1:length(nc) % the noise channels
    npar2 = na+sum(nb(1:nu));
    for kc2 = 1:length(nc)
        if kc2>=kc
            ey = eye(max(nc(kc),nc(kc2)));
            trf(npar1+1:npar1+nc(kc),npar2+1:npar2+nc(kc2)) = ...
                L(kc2,kc)*ey(1:nc(kc),1:nc(kc2));
            klc = indco(kc2,kc);
            dlnewpar(npar1+1:npar1+min(nc(kc2),nc(kc)),klc) = ...
                parold(npar2+1:npar2+min(nc(kc2),nc(kc)));
        end
        npar2 = npar2 + nc(kc2);
    end
    npar1 =npar1 + nc(kc);
end
nnf = sum(nf);
trf = [[trf,zeros(size(trf,1),nnf)];[zeros(nnf,size(trf,2)),eye(nnf)]];%lägg till ey för nf)];
dlnewpar = [dlnewpar;zeros(nnf,1)];
parnew = trf*parold;

polb = pol;
polb = parset(polb,parnew);
polb.nb = [nb(1:nu),nc];
polb.nk = [nk(1:nu),nck];
if covP
newcov = trf*covold*trf' + dlnewpar*covL*dlnewpar';
polb = pvset(polb,'CovarianceMatrix',newcov);
end
una = pvget(pol,'InputName');
str = noiprefi('v');
for kc = nu+1:nu+length(nc)
    una{kc}(1:length(str))= str;
end
polb = pvset(polb,'InputName',una);
