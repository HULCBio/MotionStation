function [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0]=ssdata(sys)
%IDSS/SSDATA  Returns state-space matrices for IDSS models.
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
%   M is an IDSS model object.
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

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/01/21 09:35:56 $

s=1;
nx = size(sys.As,1);
[nu]=size(sys.Bs,2);ny=size(sys.Cs,1);
th = pvget(sys.idmodel,'ParameterVector');
A = sys.As.'; B = sys.Bs.'; C = sys.Cs.';
D = sys.Ds.'; K = sys.Ks.'; X0 = sys.X0s;
ABCD = [A(:);B(:);C(:);D(:);K(:);X0];
ind = find(isnan(ABCD));
ABCD(ind) = th(1:length(ind));
A = reshape(ABCD(1:nx*nx),nx,nx).';
n1 = nx*nx;
B = reshape(ABCD(n1+1:n1+nx*nu),nu,nx).';
n1 = n1+nx*nu;
C = reshape(ABCD(n1+1:n1+nx*ny),nx,ny).';
n1 = n1+nx*ny;
D = reshape(ABCD(n1+1:n1+ny*nu),nu,ny).';
n1 = n1+ny*nu;
K= reshape(ABCD(n1+1:n1+ny*nx),ny,nx).';
n1 = n1+ny*nx;
X0 = ABCD(n1+1:end);
if isempty(X0),X0 = zeros(0,1);end
if nargout>6
    cov = pvget(sys.idmodel,'CovarianceMatrix');
    if isempty(cov)|ischar(cov)
        es = pvget(sys,'EstimationInfo');
        if strcmp(sys.SSParameterization,'Free')&strcmp(es.Status(1:2),'Es')
            ut = pvget(sys,'Utility');
            try
                Pm = ut.Pmodel;
            catch
                Pm = [];
            end
            if ~isempty(Pm)
                %mnan = inputname(1);
                disp(sprintf(['  The free model parameterization means that the matrix elements',...
                        '\n  have no well defined variance. To display the standard deviations',... 
                        '\n  of the matrix elements, first convert to canonical form by',...
                        '\n  %s.ss = ''can''.'],'Model'))
            end
        end
        dA = []; dB = []; dC = [];
        dD = []; dK = []; dX0 = [];
    else
        sys = parset(sys,th+sqrt(diag(cov)));
        [a1,b1,c1,d1,k1,x01] = ssdata(sys);
        dA = abs(A-a1); dB = abs(B-b1); dC = abs(C-c1);
        dD = abs(D-d1); dK = abs(K-k1); dX0 = abs(X0-x01);
    end
end
