function [model] = tfd2mod(delt,ny,g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,...
                          g11,g12,g13,g14,g15,g16,g17,g18,g19,g20,...
                          g21,g22,g23,g24,g25)
%TFD2MOD Convert transfer functions (continuous or discrete) to mod format
% 	pmod = tfd2mod(delt2,ny,g1,g2,g3,...,g25)
% TFD2MOD assumes nd=nw=nyu=0
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
% See also POLY2TFD, TFD2STEP.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% error checks:

if nargin == 0
   disp('USAGE:  pmod = tfd2mod(delt2,ny,g1,g2,g3,...,g25)')
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
for i = 1:ng
   g = eval(['g',int2str(i)]);
   [nr,nc] = size(g);
   if nr ~= 3 | nc < 2
      fprintf('ERROR IN TRANSFER FUNCTION g%.0f\n',i)
      error('T.F. must be a matrix consisting of 3 rows and 2 or more columns.')
   elseif g(3,2) < 0
      fprintf('ERROR IN TRANSFER FUNCTION g%.0f\n',i)
      error('Time delay is negative.')
   elseif g(3,1) ~= 0

%         This transfer function is already discrete-time.

      pad=zeros(1,g(3,2));  %accounts for periods of pure delay
      if round(g(3,2)) ~= g(3,2)
         fprintf('ERROR IN TRANSFER FUNCTION g%.0f\n',i)
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
      if isempty(inz)
         fprintf('ERROR IN TRANSFER FUNCTION g%.0f\n',i)
         error('T.F. denominator was zero')
      end
      if any(g(1,1:inz(1)-1) ~= 0) & inz(1) > 1
         fprintf('ERROR IN TRANSFER FUNCTION g%.0f\n',i)
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

% At this point all of the transfer functions are discrete and
% stored "side-by-side" in the matrix G.  The vector m(i)
% gives the number of columns in the ith transfer function.
% Now convert them to state-space form.  Process the transfer functions
% by columns.  Look for the lowest-common-denominator in each column (or
% a reasonable approximation to the LCD).

% Treat SISO systems as a special case for better efficiency:

if nu == 1 & ny == 1
   [a,b,c,d]=tf2ssm(g(1,:),g(2,:));
   model = ss2mod(a,b,c,d,delt);
   return
end

% Now the general case:
col0=0;
mcum=cumsum(m);
for iu = 1:nu

% First count the number of trailing zeros (units of pure time delay) in
% each denominator polynomial.  These are easy to treat as common factors.

   ig=(iu-1)*ny;
   col=col0;
   izero=[];
   for iy=1:ny
      ig=ig+1;
      inz=find(G(2,col+1:col+m(ig)) ~= 0);
      if isempty(inz);
         izero(iy)=0;
      else
         izero(iy)=m(ig)-inz(length(inz));
      end
      col=col+m(ig);
   end
   maxzero=max(izero);

% Now build up the rest of the LCD.  Add a denominator to the LCD if it
% doesn't divide evenly (i.e., with a sufficiently small remainder) into
% what is already contained in the LCD.  Note that this TFD2MOD doesn't
% check each factor of each denominator, so the resulting system may
% not be minimum-order.

   ig=(iu-1)*ny;
   [maxnz,imaxnz]=max(m(ig+1:ig+ny)-izero);      % Find the largest one to
                                                 % use as the starting point.
   if ig+imaxnz == 1
      col=col0;
   else
      col=mcum(ig+imaxnz-1);
   end
   LCD=G(2,col+1:col+m(ig+imaxnz)-izero(imaxnz));

   col=col0;
   for iy=1:ny
      ig=ig+1;
      if iy ~= imaxnz
         den=G(2,col+1:col+m(ig)-izero(iy));
         [q,r]=deconv(LCD,den);
         if max(abs(r)) > 1e-8                % This tolerance might have to be
                                              % adjusted.
            LCD=conv(LCD,den);
         end
      end
      col=col+m(ig);
   end

% Now calculate the numerator polynomials.

   NUM=[];
   ig=(iu-1)*ny;
   col=col0;
   for iy=1:ny
      ig=ig+1;
      num=G(1,col+1:col+m(ig));
      den=G(2,col+1:col+m(ig)-izero(iy));
      [q,r]=deconv(LCD,den);
      num=conv(num,q);
      num=[num zeros(1,maxzero-izero(iy))];
      [nr,nc]=size(num);
      [NR,NC]=size(NUM);
      if nc >= NC
         NUM=[zeros(NR,nc-NC) NUM
                  num             ];
      else
         NUM=[       NUM
              zeros(nr,NC-nc) num ];
      end
      col=col+m(ig);
   end

% Convert from transfer function to state-space format.
   LCD=[LCD zeros(1,maxzero)];
   [a1,b1,c1,d1] = tf2ssm(NUM,LCD);
   if iu ~= 1
      [a,b,c,d] = mpcparal(a,b,c,d,a1,b1,c1,d1);
   else
      a=a1; b=b1; c=c1; d=d1;
   end
   col0=mcum(iu*ny);
end

% Save resulting model in MPC format.

model = ss2mod(a,b,c,d,delt);

% end of function TFD2MOD.M