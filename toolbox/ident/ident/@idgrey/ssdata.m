function [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = ssdata(sys)
%IDGREY/SSDATA  Returns state-space matrices for IDGREY models.
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
%   M is the IDGREY model object.
%   The output are the matrices of the state-space model
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  in continuous or discrete time, depending on the model's sampling
%  time Ts.
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
%  returns also the model uncertainties (standard deviations) dA etc.

%
%   L. Ljung 10-2-90,11-25-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:17:02 $

mf = sys.MfileName;
if isempty(mf)
    A=[];B=[];C=[];D=[];
    K=[];X0=[];
    dA=[];dB=[];dC=[];dD=[];
    dK=[];dX0=[];
    return
end


th = pvget(sys.idmodel,'ParameterVector');
Ts = pvget(sys.idmodel,'Ts');
cd = sys.CDmfile;
arg = sys.FileArgument;
if strcmp(cd,'c')&Ts>0
    error(sprintf(['This model cannot return discrete time models.\n'...
            'Either set Ts to zero for continuous time or sample by C2D.',...
            '\n(Note that a continuous time model automatically is adjusted to the',...
            '\ndata sampling interval for simulation and estimation.)']))
elseif strcmp(cd,'d')&Ts==0
    error(sprintf(['This model cannot return continuous time models.\n'...
            'Either set Ts >0 for discrete time or convert by D2C.']))
else
    [A,B,C,D,K,X0]=feval(mf,th,Ts,arg);
end
ut = pvget(sys,'Utility');
switch sys.InitialState
    case 'Zero'
        X0 = zeros(size(X0));
    case {'Estimate','Fixed'}
        try
            X0 = ut.X0;
            if size(X0,1)<size(A,1)
                X0 = [X0;zeros(size(A,1)-size(X0,1),1)];
            end
        end
    case 'x0'
        if length(X0)>0
        X0 = th(end-length(X0)+1:end);
    end
end
if ~isa(sys,'idproc');
switch sys.DisturbanceModel
    case 'None'
        K = zeros(size(K));
    case {'Estimate','Fixed'}
        try
            K = ut.K;
        catch
            K = zeros(size(K));
        end
    case 'K'
        [nxk,nyk] = size(K);
        if strcmp(sys.InitialState,'x0')
            nend = length(X0);
        else
            nend = 0;
        end
        K = th(end-nend-nxk*nyk+1:end-nend);
        K = reshape(K,nxk,nyk);
end
end

% Now for possible subchannel selections:      

try
    ind = ut.index;
    flag = ind.flag;
catch
    flag = 0;
end
if flag
    [ny,nu]=size(D);
    uind =ind.uind;
    if ind.flagall
        L = chol(ind.lambda);
        %idm = sys.idmodel;
        L = L'; % is now lower triangular
        % the cholesky fcator is such that e = L*v with v unit covariance
        B0 = B;
        D0 = D;
        B = [B K*L];     
        D = [D, L];
        uind = [1:ny+nu];
    elseif ind.flagm
        K = zeros(size(K));  
    end
    B = B(:,uind);
    C = C(ind.yind,:);
    D = D(ind.yind,uind);
    K = K(:,ind.yind);
end

if nargout>6
    dA=[];dB=[];dC=[];dD=[];dK=[];dX0=[];
    P =pvget(sys,'CovarianceMatrix');
    if isempty(P),return,end
    if flag,
        if ind.flagall
            try
                ei = pvget(sys,'EstimationInfo');
                Ncap = ei.DataLength;
                if isempty(Ncap)
                    Ncap = inf;
                end
            catch
                Ncap = inf;
            end
            P1 = covlamb(L,Ncap);
            s = 1;
            for ky=1:ny
                for k2 = 1:ky
                    lcol(s) = L(ky,k2);
                    s=s+1;
                end
            end
            %th= [th;lcol(:)];
            P = [[P,zeros(size(P,1),size(P1,2))];[zeros(size(P1,1),size(P,2)),P1]];
        end,end
    nth = nuderst(th.');
    [nx]= size(A,1);[ny,nu]=size(D);
    acbvec = [A(:);B(:);C(:);D(:);K(:);X0];
    mm = zeros(nx^2+nx*ny*2+nx*nu+nu*ny+nx,length(th));
    for kk = 1:length(th) % When flagall, add L to parameter list
        % and use L's covariance matrix in covlamb
        th1 = th;
        th1(kk)=th1(kk) + nth(kk);
        sys1 = parset(sys,th1);
        [A1,B1,C1,D1,K1,X01] = ssdata(sys1);
        mm(:,kk) = ([A1(:);B1(:);C1(:);D1(:);K1(:);X01]-acbvec)/nth(kk);
    end
    if flag,if ind.flagall
            kk = length(th)+1;
            nl = nuderst(lcol(:)');
            cc = 1;
            for ky = 1:ny  
                for k2 = 1:ky
                    nll = nl(cc);
                    L1 = L;
                    L1(ky,k2) = L1(ky,k2)+nll;
                    B1 = [B0 K*L1];     
                    D1 = [D0, L1];
                    mm(:,kk) = ([A(:);B1(:);C(:);D1(:);K(:);X0]-acbvec)/nll;
                    kk = kk+1;cc = cc+1;
                end
            end
        end,end
    pab = sqrt(diag(mm*P*mm'));
    dA = reshape(pab(1:nx*nx),nx,nx);pab=pab(nx^2+1:end);
    dB = reshape(pab(1:nx*nu),nx,nu);pab=pab(nx*nu+1:end);
    dC = reshape(pab(1:nx*ny),ny,nx);pab=pab(nx*ny+1:end);
    dD = reshape(pab(1:ny*nu),ny,nu);pab=pab(ny*nu+1:end);
    dK = reshape(pab(1:ny*nx),nx,ny);pab=pab(ny*nx+1:end);
    dX0 = pab;
    
end



