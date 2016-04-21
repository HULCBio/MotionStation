function [ahed,bhed,ched,dhed,aug,hsv] = bstschmr(varargin)
%BSTSCHMR Balanced stochastic truncation (BST) model reduction.
%
% [SS_H,AUG,HSV] = BSTSCHMR(SS_,MRTYPE,NO,INFO) or
% [AHED,BHED,CHED,DHED,AUG,HSV]=BSTSCHMR(A,B,C,D,MRTYPE,NO,INFO) performs
%    relative error Schur model reduction on a SQUARE, STABLE G(s):=
%    (A,B,C,D). The infinity-norm of the relative error is bounded as
%               -1                             n
%            |Gm (s)(Gm(s)-G(s))|    <= 2 * ( SUM  si / (1 - si) )
%                                inf          k+1
%    where si denotes the i-th Hankel singular value of the all-pass
%    "phase matrix" of G(s).
%    The algorithm is based on the Balanced Stochastic Truncation (BST)
%    theory with Relative Error Method (REM).
%    Based on the "MRTYPE" selected, you have the following options:
%     1). MRTYPE = 1  --- no: size "k" of the reduced order model.
%     2). MRTYPE = 2  --- find k-th order reduced model that
%                         tolerance (db) <= "no".
%     3). MRTYPE = 3  --- display all the Hankel SV of phase matrix and
%                   prompt for "k" (in this case, no need to specify "no").
%    Input variable: "info" = 'left '; or 'right' (default value)
%    Output variable "aug": aug(1,1) = no. of state removed
%                           aug(1,2) = relative error bound
%    Note that if D is not full rank, an error will result.

% R. Y. Chiang & M. G. Safonov 2/30/88
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ---------------------------------------------------------------------------

nag1 = nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,mrtype,no,info]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end
nag1 = nargin;     % NARGIN may have changed

[rd,cd] = size(D);
if nag1 == 6
   info = 'right';
end
%
if (info == 'left ') | (rd < cd)
   A = A'; temp = B; B = C'; C = temp'; D = D';
end
%
if rank(D*D') < min([rd, cd])
  disp('   WARNING: D MATRIX IS NOT FULL RANK - - -');
  disp('            THE PROBLEM IS ILL-CONDITIONED !');
  return
end
%
disp(' ')
disp('        - - Working on Schur BST-REM model reduction - -');
[ma,na] = size(A);
P = gram(A,B);
G = P*C'+B*D';
phi = D*D';
%
qrnQ = [zeros(ma) -C';-C -phi];
[K,Q,Qerr] = lqrc(A,G,qrnQ);
%
lambda = eig(P*Q);
hsv = sqrt(lambda);
[hsv,index] = sort(real(hsv));
hsv = hsv(ma:-1:1,:);
%
% ------ Model reduction based on your choice of mrtype:
%
if mrtype == 1
   kk = no+1;
end
%
if mrtype == 2
   toldb = no;    %in db
   tolabs = 10^(toldb/20);
   resig = 0;
   for i = ma:-1:1
      resig = resig + hsv(i)/(1-hsv(i));
      rem = 2*resig;
      if rem > tolabs
         kk = i+1;
         break
      end
   end
end
%
if mrtype == 3
   format short e
   format compact
   [mhsv,nhsv] = size(hsv);
   if mhsv < 60
      disp('    Hankel Singular Values:')
      hsv'
      for i = 1:mhsv
        if hsv(i) == 0
           hsvp(i) = eps;
        else
           hsvp(i) = hsv(i);
        end
      end
      disp(' ')
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      no = input('Please assign the k-th index for k-th order model reduction: ');
   else
      disp('    Hankel Singular Values:')
      hsv(1:60,:)'
      disp('                              (strike a key for more ...)')
      pause
      hsv(61:mhsv,:)'
      for i = 1:mhsv
        if hsv(i) == 0
           hsvp(i) = eps;
        else
           hsvp(i) = hsv(i);
        end
      end
      disp(' ')
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      no = input('Please assign the k-th index for k-th order model reduction: ');
   end
   format loose
   kk = no + 1;
end
%
% ------ Save all the states:
%
if kk > na
   ahed = A; bhed = B; ched = C; dhed = D;
   aug = [0 0];
   return
end
%
% ------ Disgard all the states:
%
if kk < 1
   ahed = zeros(ma,na);   bhed = zeros(ma,nd);
   ched = zeros(md,na);   dhed = zeros(md,nd);
   resig = 0;
   for i = 1:na
      resig = resig + hsv(i)/(1-hsv(i));
   end
   rem = 2*resig;
   aug = [na rem];
   return
end
%
% ------ Computing the relative error bound:
%
resig = 0;
for i = kk:na
    resig = resig + hsv(i)/(1-hsv(i));
end
rem = 2*resig;
strm = na-kk+1;
aug = [strm rem];
%
% ---------------------- Start Model Reduction:
%
% ------ Find the left-eigenspace basis:
%
ro = (hsv(kk-1)^2+hsv(kk)^2)/2.;
gammaa = P*Q-ro*eye(na);
[va,ta,msa] = blkrsch(gammaa,1,na-kk+1);
vlbig = va(:,(na-kk+2):na);
%
% ------ Find the right-eigenspace basis:
%
gammad = -gammaa;
[vd,td,msd] = blkrsch(gammad,1,kk-1);
vrbig = vd(:,1:kk-1);
%
% ------ Find the similarity transformation:
%
ee = vlbig'*vrbig;
[ue,se,ve] = svd(ee);
%
seih = diag(ones(kk-1,1)./sqrt(diag(se)));
slbig = vlbig*ue*seih;
srbig = vrbig*ve*seih;
%
ahed = slbig'*A*srbig;
bhed = slbig'*B;
ched = C*srbig;
dhed = D;
%
if (info == 'left ') | (rd < cd)
  ahed = ahed'; temp = bhed;
  bhed = ched'; ched = temp'; dhed = dhed';
end
%
if xsflag
   ahed = mksys(ahed,bhed,ched,dhed);
   bhed = aug;
   ched = hsv;
end
%
disp(' ')
disp(['               ' int2str(aug(1,1)), '    states removed !!'])
%
% ------ End of BSTSCHMR.M --- RYC/MGS %