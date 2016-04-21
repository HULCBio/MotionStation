function [a,b1,b2,c1,c2,d11,d12,d21,d22] = augtf(varargin)
%AUGTF Augmentation of W1,W2,W3 (transfer function form) into two-port plant.
%
% [TSS_] = AUGTF(SS_G,W1,W2,W3) or
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGTF(AG,BG,CG,DG,W1,W2,W3)
% produces an augmented state-space realization for H2/Hinf control
% system design, where
%         ss_g = mksys(ag,bg,cg,dg); (original plant state-space)
%
%         w1   = diagonal weighting matrix on "e"
%              = [N11;D11;N22;D22;....]
%
%         w2   = diagonal weighting matrix on "u"
%              = [N11;D11;N22;D22;....]
%
%         w3   = diagonal weighting matrix on "y", but allow polynomial
%         matrix at frequency infinity (i.e., w3(s) = sysw3 + w3poly(s))
%              = [N11;D11;N22;D22;....]
%
%  The resulting state-space sysw1, sysw2, and W3(s) = sysw3 + w3poly(s)
%  are passed on to AUGSS.M to compute the final state-space.
%
%  If one of the weightings is missing, simply assign an empty bracket: [].

% R. Y. Chiang & M. G. Safonov 1/87
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.12.4.3 $
% All Rights Reserved.
% --------------------------------------------------------------------
n=[];
nin = nargin;
[emsg,nag1,xsflag,Ts,ag,bg,cg,dg,w1,w2,w3]=mkargs5x('ss,lti',varargin); error(emsg);

%% WAS added 3 lines to initialize with empty matrices
aw1=[];bw1=[];cw1=[];dw1=[];
aw2=[];bw2=[];cw2=[];dw2=[];
aw3=[];bw3=[];cw3=[];dw3=[];

% Check for nondiagonal lti weights
error(nondiag(w1));
error(nondiag(w2));
error(nondiag(w3));

% Convert LTI's and/or scalar weights, if needed:
w1=lti2w(w1);
w2=lti2w(w2);
w3=lti2w(w3);

if norm(w1,inf) == 0, w1 = []; end
if norm(w2,inf) == 0, w2 = []; end
if norm(w3,inf) == 0, w3 = []; end
%
% ------ Assemble the state-space quadruple of W1:
%
[mw1,nw1] = size(w1);
%
for i = 1:mw1/2
    numw1 = w1(2*i-1,:);
    denw1 = w1(2*i,:);
    if norm(denw1,inf) == 0 & norm(numw1,inf) ~= 0
       error('    W1 Denominator is zero !!')
    end
    numw1p = numw1; denw1p = denw1;
    if norm(numw1,inf) ~= 0
       p = 1;                          % strip out leading zeros of 'numw1'
       while numw1(1,p) == 0
          numw1p = numw1(1,p+1:nw1);
          p = p+1;
       end
       p = 1;
       while denw1(1,p) == 0           % strip out leading zeros of 'denw1'
          denw1p = denw1(1,p+1:nw1);
          p = p+1;
       end
    else
       numw1p = 0;
       denw1p = 1;
    end
    if ((size(numw1p)-size(denw1p))*[0;1])>0
        error('     Error: W1(s) is not proper !!')
    end
    [aw1p,bw1p,cw1p,dw1p] = tf2ss(numw1p,denw1p);
    if i == 1
       aw1 = aw1p; bw1 = bw1p; cw1 = cw1p; dw1 = dw1p;
    else
       [aw1,bw1,cw1,dw1] = append(aw1,bw1,cw1,dw1,aw1p,bw1p,cw1p,dw1p);
    end
end
%
% ------ Assemble the state-space quadruple of W2:
%
[mw2,nw2] = size(w2);
%
for i = 1:mw2/2
    numw2 = w2(2*i-1,:);
    denw2 = w2(2*i,:);
    if norm(denw2,inf) == 0 & norm(numw2,inf) ~= 0
       error('    W2 Denominator is zero !!')
    end
    numw2p = numw2; denw2p = denw2;
    if norm(numw2,inf) ~= 0
       p = 1;                          % strip out leading zeros of 'numw2'
       while numw2(1,p) == 0
          numw2p = numw2(1,p+1:nw2);
          p = p+1;
       end
       p = 1;
       while denw2(1,p) == 0           % strip out leading zeros of 'denw2'
          denw2p = denw2(1,p+1:nw2);
          p = p+1;
       end
    else
       numw2p = 0;
       denw2p = 1;
    end
    if ((size(numw2p)-size(denw2p))*[0;1])>0
        error('     Error: W2(s) is not proper !!')
    end
    [aw2p,bw2p,cw2p,dw2p] = tf2ss(numw2p,denw2p);
    if i == 1
       aw2 = aw2p; bw2 = bw2p; cw2 = cw2p; dw2 = dw2p;
    else
       [aw2,bw2,cw2,dw2] = append(aw2,bw2,cw2,dw2,aw2p,bw2p,cw2p,dw2p);
    end
end
%
% ------ Assemble the state-space quadruple of W3:
%

if ~isempty(w3),
   [mw3,nw3] = size(w3);
   n = mw3/2;
   N = nw3;
   w3poly = zeros(n,N*n);
else
   w3poly=[];
end
%%
for i = 1:n
    numw3 = w3(2*i-1,:);
    denw3 = w3(2*i,:);
    if norm(denw3,inf) == 0 & norm(numw3,inf) ~= 0
       error('    W3 Denominator is zero !!')
    end
    numw3p = numw3; denw3p = denw3;
    if norm(numw3,inf) ~= 0
       p = 1;
       while denw3(1,p) == 0    % strip out leading zeros of 'denw3'
          denw3p = denw3(1,p+1:nw3);
          p = p+1;
       end
    else
       denw3p = 1;
    end
    [qw3,rw3] = deconv(numw3p,denw3p); % deconvolution of (numw3,denw3)
    [mrw3,nrw3] = size(rw3);
    [mqw3,nqw3] = size(qw3);
    if norm(rw3,inf) < 1.e-14     % fix the numerical error from deconv
       rw3 = zeros(mrw3,nrw3);
    end                            % end of the fix
    if nqw3 < N
       qw3 = [zeros(1,N-nqw3) qw3];
    end
    aw3p = []; bw3p = zeros(0,1); cw3p = zeros(1,0); dw3p = 0;
    if norm(rw3,inf) ~= 0
       p = 1;                   % strip out leading zeros of 'rw3'
       while abs(rw3(1,p)) < 1.e-12
             rw3p = rw3(1,p+1:nrw3);
             p = p+1;
       end
       [aw3p,bw3p,cw3p,dw3p] = tf2ss(rw3p,denw3p);  % strictly proper tf
    end
    [aw3,bw3,cw3,dw3] = append(aw3,bw3,cw3,dw3,aw3p,bw3p,cw3p,dw3p);
    for j = 0:N-1                                % non-proper part
        w3poly(i,j*n+i)=qw3(1,j+1);
    end
end
%
% ------ State-space augmentation with W(3) = sysw3 + w3poly:
%
[a,b1,b2,c1,c2,d11,d12,d21,d22] = augss(ag,bg,cg,dg,aw1,bw1,cw1,dw1,...
        aw2,bw2,cw2,dw2,aw3,bw3,cw3,dw3,w3poly);
%
if xsflag,
   if ~isa(varargin{1},'lti'), 
      a = mksys(a,b1,b2,c1,c2,d11,d12,d21,d22,Ts,'tss');
   else
      a = mklti(a,b1,b2,c1,c2,d11,d12,d21,d22,Ts,'tss');
   end
end
%
% ------------- End of AUGTF.M  % RYC/MGS 10/19/1988 %

function [w,wpoly]=lti2w(sys)
% W = LTI2w(SYS) converts both LTI SYS and 
%   scalar gain SYS to AUGTF weight W.
%   See AUGTF for details
wpoly=[];
if ~isa(sys,'lti'),
   % Convert scalar weights to tranfer function equivalent
   if isa(sys,'double') & isequal(size(sys),[ 1 1 ]),
      sys=[sys; 1];
   end
   w=sys; 
   return, 
end
[rw,cw]=size(sys);

% if sys is square, set sys=diag(sys)
if rw==cw & rw>1,
   num=get(sys,'num');
   den=get(sys,'den');
   sys=tf(diag(num),diag(den));
end

[nummat,denmat,rows,cols]=branch(tf(sys));
if size(denmat,1)==1,
   denmat=ones(rows,1)*denmat;
end

w=zeros(2*rw,size(nummat,2));

w(1:2:end-1,:)=nummat;
w(2:2:end,:)=denmat;

% ------------- End of LTI2W.M  % RYC/MGS 4/19/98 %

function emsg=nondiag(sys);
% isdiag  TRUE if object is LTI 
emsg='';
if ~isa(sys,'lti'), return, end

[rs,cs]=size(sys);
if cs==1,
   return
elseif rs~=cs,
   emsg='LTI weightings W1(s), W2(s) and W3(s) must be either square diagonal matrices or column vectors';
else
   nums=get(sys,'num');
   odnums=nums(find(~eye(rs)));
   if any(cat(2,odnums{:})),
      emsg='LTI weightings W1(s), W2(s) and W3(s) must be either square diagonal matrices or column vectors';
   end
end
% ------------- End of NONDIAG.M  % RYC/MGS 4/19/98 %
