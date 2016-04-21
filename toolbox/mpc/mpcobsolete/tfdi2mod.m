function [model] = tfdi2mod(delt,ny,g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,...
                          g11,g12,g13,g14,g15,g16,g17,g18,g19,g20,...
                          g21,g22,g23,g24,g25)
%TFDI2MOD Convert transfer functions (continuous or discrete) to mod format
% 	pmod = tfdi2mod(delt2,ny,g1,g2,g3,...,g25)
% TFDI2MOD assumes nd=nw=nyu=0
%
% Inputs:
%  delt2   :  sampling period for system.
%  ny      :  number of outputs.
%  gi = [  b0   b1   b2  ... ]   Each gi is a transfer function in the
%       |  a0   a1   a2  ... |   form created by POLY2TFD.  See that
%       [ delt delay  0  ... ]   function for more details.
%
% Output:
%  pmod   :  The model in the "mod" format required by MPC toolbox.
%
% See also TFD2MOD, POLY2TFD, TFD2STEP.
%
% NOTE:  As for TFD2MOD, but  does not attempt to use lowest-common
%        denominator in SIMO construction.  This avoids numerical
%        problems caused by manipulation of polynomials.  TFDI2MOD
%        is strongly recommended for high-order systems.  Only
%        disadvantage is possible non-minimal state-space
%        realization.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% error checks:

if nargin == 0
   disp('USAGE:  pmod = tfdi2mod(delt2,ny,g1,g2,g3,...,g25)')
   return
end

ng = nargin-2;
nu = ng/ny;

if fix(nu) ~= nu
    error(' Number of transfer functions must be multiple of NY')
end
if length(delt)~=1
    error('The sampling period must be a scalar.')
elseif delt <= 0
    error('The sampling period must be > 0')
end
if (nargin < 3)
   error(' Too few input arguments.');
end

% Process each tf, converting to discrete time where necessary.

G=[];
errform='ERROR IN TRANSFER FUNCTION g%.0f\n';
for i = 1:ng
   g = eval(['g',int2str(i)]);
   [nr,nc] = size(g);
   if nr ~= 3 | nc < 2
      fprintf(errform,i)
      error('T.F. must be a matrix consisting of 3 rows and 2 or more columns.')
   elseif all(g(2,:) == 0)
      fprintf(errform,i)
      error('The denominator is zero.')
   elseif g(3,2) < 0
      fprintf(errform,i)
      error('Time delay is negative.')
   elseif g(3,1) ~= 0

%         This transfer function is already discrete-time.

      pad=zeros(1,g(3,2));  % accounts for periods of pure delay
      if round(g(3,2)) ~= g(3,2)
         fprintf(errform,i)
         error('Time delay must be an integer.')
      elseif g(3,1) ~= delt

%            Change the sampling period by converting to continuous, then
%            back to discrete.  (Prints warning message).

         fprintf('WARNING:  change in sampling period for T.F. g%.0f\n',i)
         [a,b,c,d]=tf2ssm([pad g(1,:)],[g(2,:) pad]);
         [a,b]=d2cmp(a,b,g(3,1));
         [a,b]=c2dmp(a,b,delt);
         [numd,dend]=ss2tf2(a,b,c,d,1);
         g=[numd;dend];

      elseif g(3,2) > 0
         g=[ [pad g(1,:)] ; [g(2,:) pad] ];
      end
      [nr,nc]=size(g);          % Update number of columns
      inz = find(g(2,:) ~= 0);  % Check for leading zeros in the denominator
      if any(g(1,1:inz(1)-1) ~= 0) & inz(1) > 1
         fprintf(errform,i)
         error('Order of numerator greater than denominator')
      else
         g=g(1:2,inz(1):nc);    % Strips off leading zeros, if any.
      end
   else
      [numd,dend]=cp2dp(g(1,:),g(2,:),delt,g(3,2));  % Convert to discrete.
      g=[numd;dend];
   end
   [nr,m(i)]=size(g);
   G = [G g(1:2,:)];
end

% All of the transfer functions are discrete and have now been
% stored "side-by-side" in the matrix G.  The vector m(i)
% gives the number of columns in the ith transfer function.
% Next convert them to state-space form.  Process the transfer functions
% by columns.

% Treat SISO systems as a special case for better efficiency:

if nu == 1 & ny == 1
   [a,b,c,d]=tf2ssm(g(1,:),g(2,:));
   model = ss2mod(a,b,c,d,delt);
   return
end

% Now the general case.  Build up the composite
% system by forming a SIMO system for each input,
% then connecting these SIMO systems in parallel.

col0=0;
ig=0;
for iu = 1:nu

   izero=[];
   for iy=1:ny
      ig=ig+1;
      cols=[col0+1:col0+m(ig)];  % Points to columns for this T.F.
      col0=col0+m(ig);
      NUM=G(1,cols);
      DEN=G(2,cols);
      inzn=find(NUM ~= 0);
      inzd=find(DEN ~= 0);
      nnzd=length(inzd);
      if isempty(inzn)
         leadz=m(ig);
      else
         leadz=inzn(1)-1;             % number of leading zeros in NUM
      end
      trailz=m(ig)-inzd(nnzd);        % number of trailing zeros in DEN
      izero(iy)=min([leadz trailz]);  % units of delay for this T.F.

% Get the delay-free state-space realization for this T.F.

      if izero(iy) > 0
         NUM=NUM(1,izero(iy)+1:m(ig));
         DEN=DEN(1,1:m(ig)-izero(iy));
      end
      [a1,b1,c1,d1] = tf2ssm(NUM,DEN);

% If more than one output, append this one to previous.

      if iy == 1
         a2=a1; b2=b1; c2=c1; d2=d1;
         rows=[1 length(a1)];
      else
         n2=length(a2);
         n1=length(a1);
         rows(iy,:)=[rows(iy-1,2)+1  rows(iy-1,2)+n1];
         a2=[a2 zeros(n2,n1) ; zeros(n1,n2) a1];
         b2=[b2 ; b1];
         c2=[c2 zeros(iy-1,n1) ; zeros(1,n2) c1];
         d2=[d2 ; d1];
      end
   end
   maxzero=max(izero);     % The largest delay for this input

% If this input has delay, account for it now by adding new
% states to represent the delayed input, then making required
% connections to each delay-free system.

   if maxzero > 0

      n2=length(a2);
      if maxzero > 1
         a1=diag(ones(1,maxzero-1),-1);
         b1=[1;zeros(maxzero-1,1)];
      else
         a1=0;
         b1=1;
      end
      a2=[a2 zeros(n2,maxzero) ; zeros(maxzero,n2) a1];
      b2=[b2 ; b1];
      c2=[c2 zeros(ny,maxzero)];

      for iy=1:ny
         if izero(iy) > 0
            irows=[rows(iy,1):rows(iy,2)];
            a2(irows,n2+izero(iy))=b2(irows,1);  % connects to delayed input
            c2(iy,n2+izero(iy))=d2(iy,1);
            b2(irows,1)=zeros(length(irows),1);  % disconnects from input
            d2(iy,1)=0;
         end
      end
   end

% Put this SIMO system in parallel with those for previous inputs.

   if iu ~= 1
      [a,b,c,d] = mpcparal(a,b,c,d,a2,b2,c2,d2);
   else
      a=a2; b=b2; c=c2; d=d2;
   end
end

% Save resulting model in MPC format.

model = ss2mod(a,b,c,d,delt);

% end of function TFD2MOD.M
