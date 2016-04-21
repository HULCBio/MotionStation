function [b,a]=invfreqz(g,w,varargin)
%INVFREQZ  Discrete filter least squares fit to frequency response data.
%   [B,A] = INVFREQZ(H,W,NB,NA) gives real numerator and denominator 
%   coefficients B and A of orders NB and NA respectively, where
%   H is the desired complex frequency response of the system at frequency
%   points W, and W contains the normalized frequency values within the 
%   interval [0, Pi] (W is in units of radians/sample).
%
%   INVFREQZ yields a filter with real coefficients.  This means that it is 
%   sufficient to specify positive frequencies only; the filter fits the data 
%   conj(H) at -W, ensuring the proper frequency domain symmetry for a real 
%   filter.
%
%   [B,A] = INVFREQZ(H,W,NB,NA,Wt) allows the fit-errors to be weighted
%   versus frequency.  LENGTH(Wt)=LENGTH(W)=LENGTH(H).
%   Determined by minimization of sum |B-H*A|^2*Wt over the freqs in W.
%
%   [B,A] = INVFREQZ(H,W,NB,NA,Wt,ITER) does another type of fit:
%   Sum |B/A-H|^2*Wt is minimized with respect to the coefficients in B and
%   A by numerical search in at most ITER iterations.  The A-polynomial is 
%   then constrained to be stable.  [B,A]=INVFREQZ(H,W,NB,NA,Wt,ITER,TOL)
%   stops the iterations when the norm of the gradient is less than TOL.
%   The default value of TOL is 0.01.  The default value of Wt is all ones.
%   This default value is also obtained by Wt=[].
%
%   [B,A] = INVFREQZ(H,W,NB,NA,Wt,ITER,TOL,'trace') provides a textual
%   progress report of the iteration.
%
%   [B,A] = INVFREQZ(H,W,'complex',NB,NA,...) creates a complex filter.  In 
%   this case, no symmetry is enforced and W contains normalized frequency
%   values within the interval [-Pi, Pi].
%
%   See also FREQZ, FREQS, INVFREQS.

%   Author(s): J.O. Smith and J.N. Little, 4-23-86
%              J.N. Little, 4-27-88, revised 
%              Lennart Ljung, 9-21-92, rewritten
%              T. Krauss, 10-19-92, trace mode made optional
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:12:16 $

% calling sequence is
%function [b,a]=invfreqz(g,w,nb,na,wf,maxiter,tol,pf)
% OR
%function [b,a]=invfreqz(g,w,'complex',nb,na,wf,maxiter,tol,pf)
error(nargchk(4,9,nargin))
if isstr(varargin{1})
    realStr = lower(varargin{1});
    varargin(1) = [];
else
    realStr = 'real';
end
gaussFlag = length(varargin)>3;  % run Gauss-Newton algorithm or not?
if length(varargin)<6
    varargin{6} = [];  % pad varargin with []'s
end
[nb,na,wf,maxiter,tol,pf] = deal(varargin{:});

switch realStr
case 'real'
    realFlag = 1;
case 'complex'
    realFlag = 0;
otherwise
    warning(...
    sprintf('String ''%s'' not recognized.  I assume you meant ''complex''.',...
            realStr))
    realFlag = 0;
end

nk=0;T=1; % The code is prepared for arbitrary sampling interval T and for
          % constraining the numerator to begin with nk zeros.

nb=nb+nk+1;
if isempty(pf)
    verb=0;
elseif (strcmp(pf,'trace')),
    verb=1;
else
    error(['Trace flag ''' pf ''' not recognizable']);
end
if isempty(wf),wf=ones(length(w),1);end
wf=sqrt(wf);

if length(g)~=length(w),error('The lengths of H and W must coincide'),end
if length(wf)~=length(w),error('The lengths of Wt and W must coincide'),end
if any( (w>pi) | (w<0) ) & realFlag
    warnStr = sprintf(...
     ['W has values outside the interval [0,pi]. INVFREQZ aliases such\n' ...
      'values into this interval and designs a real filter.\n' ...
      'To design a complex filter, use the ''complex'' flag.']);
    warning(warnStr)
end
[rw,cw]=size(w);if rw>cw w=w';end
[rg,cg]=size(g);if cg>rg g=g.';end
[rwf,cwf]=size(wf);if cwf>rwf wf=wf';end

nm=max(na,nb+nk-1);
OM=exp(-i*[0:nm]'*w*T);

%
% Estimation in the least squares case:
%
Dva=(OM(2:na+1,:).').*(g*ones(1,na));
Dvb=-(OM(nk+1:nk+nb,:).');
D=[Dva Dvb].*(wf*ones(1,na+nb));
if realFlag
    R=real(D'*D);
    Vd=real(D'*(-g.*wf));
else
    R=D'*D;
    Vd=D'*(-g.*wf);
end
th=R\Vd;
a=[1 th(1:na).'];b=[zeros(1,nk) th(na+1:na+nb).'];

if ~gaussFlag,return,end

% Now for the iterative minimization
if isempty(maxiter), maxiter = 30; end

if isempty(tol)
    tol = 0.01;
end
indb=1:length(b);indg=1:length(a);
a=polystab(a); % Stabilizing the denominator

% The initial estimate:

GC=((b*OM(indb,:))./(a*OM(indg,:))).';
e=(GC-g).*wf;
Vcap=e'*e; t=[a(2:na+1) b(nk+1:nk+nb)].';
if (verb),
    clc, disp(['  INITIAL ESTIMATE'])	
    disp(['Current fit: ' num2str(Vcap)])
    disp(['par-vector'])
    disp(t)
end;

%
% ** the minimization loop **
%
gndir=2*tol+1;l=0;st=0;
while [norm(gndir)>tol l<maxiter st~=1]
    l=l+1;

    %     * compute gradient *

    D31=(OM(2:na+1,:).').*(-GC./((a*OM(1:na+1,:)).')*ones(1,na));
    D32=(OM(nk+1:nk+nb,:).')./((a*OM(1:na+1,:)).'*ones(1,nb));
    D3=[D31 D32].*(wf*ones(1,na+nb));

    %     * compute Gauss-Newton search direction *
    
    e=(GC-g).*wf;
    if realFlag
        R=real(D3'*D3);
        Vd=real(D3'*e);
    else
        R=D3'*D3;
        Vd=D3'*e;
    end
    gndir=R\Vd;
    
    %     * search along the gndir-direction *

    ll=0;,k=1;V1=Vcap+1;
    while [V1 > Vcap ll<20],

        t1=t-k*gndir; if ll==19,t1=t;end
        a=polystab([1 t1(1:na).']);
        t1(1:na)=a(2:na+1).';   %Stabilizing denominator
        b=[zeros(1,nk) t1(na+1:na+nb).'];
        GC=((b*OM(indb,:))./(a*OM(indg,:))).';
        V1=((GC-g).*wf)'*((GC-g).*wf); t1=[a(2:na+1) b(nk+1:nk+nb)].';
        if (verb),
            home, disp(int2str(ll))
        end;
        k=k/2;
        ll=ll+1; if ll==20, st=1;end
        if ll==10,gndir=Vd/norm(R)*length(R);k=1;end
    end
    
    if (verb),
        home
        disp(['      ITERATION # ' int2str(l)])
        disp(['Current fit:  ' num2str(V1) '  Previous fit:  ',...
                num2str(Vcap)])
        disp(['Current par prev.par   GN-dir'])
        disp([t1 t gndir])
        disp(['Norm of GN-vector: ' num2str(norm(gndir))])
        if st==1, 
            disp(['No improvement of the criterion possible along ',...
                    'the search direction']), 
            disp('Iterations therefore terminated'),
        end
    end
    t=t1; Vcap=V1;
end
