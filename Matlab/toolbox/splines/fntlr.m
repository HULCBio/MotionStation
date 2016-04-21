function out = fntlr(f,dorder,x,interv)
%FNTLR Taylor coefficients or polynomial
%
%   FNTLR(F,DORDER,X)  returns the Taylor coefficients of F to order DORDER
%   at X, that is, the DORDER Taylor-vector
%
%      T(F,DORDER,X) := [F(X); DF(X); ...; D^(DORDER-1)F(X)]
%
%   in case F is univariate and X is a scalar.
%
%   If, more generally, X is a matrix, then the matrix, obtained from X by
%   replacing each entry by its corresponding Taylor-vector, is returned.
%
%   If, more generally, F is d-valued with d>1 or even length(d)>1 and/or
%   is m-variate for some m>1, then DORDER is expected to be an m-vector
%   of positive integers, X is expected to be a matrix with m rows, and, in 
%   that case, the output is of size [prod(d)*prod(DORDER),size(x,2)], with 
%   its j-th column containing
%
%     T(F,DORDER,X(:,j))(i1,...,im) = D_1^{i1-1}...D_m^{im-1}F(X(:,j))
%
%                                       i1=1:DORDER(1), ..., im=1:DORDER(m).
%
%   FNTLR(F,DORDER,X,INTERV)  returns the ppform with the given basic interval,
%   of the Taylor polynomial at X of order DORDER, for the m-variate function 
%   described by F, provided X is of size [m,1], and INTERV is of size [m,2].
%
%   For example, fntlr(f,3,x) should produce the same output as would
%
%   df = fnder(f); [fnval(f,x); fnval(df,x); fnval(fnder(df),x)]
%
%   This is particularly helpful in case the function described by f is a 
%   rational spline, in which case fnder(f) will only produce an error message.
%   For example, the following provides a plot of the famous Runge function
%   and its first derivative:
%      runge = rpmak([-5 5],[0 0 1; 1 -10 26],1);  x = -5:.1:5;
%      tlr = fntlr(runge,2,x);
%      plot(x,tlr)
%   
%   For example, if f describes a piecewise bicubic function, then
%
%   tp = fntlr(f,[4 4],[0;0],[-1 1;-1 1]);
%
%   describes a polynomial that agrees with that function on the
%   break-rectangle that contains the origin, (0,0).
%
%   See also FNDER, FNDIR, FNVAL.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2003/04/25 21:12:17 $

if nargin<2, dorder=1; end

if ~isstruct(f), f = fn2fm(f); end

% The output is expected to be a matrix-valued matrix of size(x), with each
% entry the DORDER Taylor-matrix for f at that point, i.e., the matrix
%     T(F,DORDER,X)(i1,...,im) = D_1^{i1-1}...D_m^{im-1}F(X)
%                                       i1=1:DORDER(1), ..., im=1:DORDER(m),
% while each entry of this m-array is of size [prod(d),1].
%

% For simplicity of programming this the first time around, handle it this way:
%  1. put together the spline 
%                S_1(x) := [F(x);D_1F(x);...;D_1^{DORDER(1)-1}F(x)]
%     (simply by concatenating its coefficients, being sure to treat them all as
%     pp of the same order; using fndir rather than fnder would do that trick).
%  2. Put together the spline 
%              S_2(x) := [S_1(X);D_2S_1(X);...;D_2^{DORDER(2)-1}S_2(X)]
%  etc
% After the m-th step, evaluate the resulting S_m at X.
% 
% Possible improvements: for a few scattered x, it may be more efficient to
% select, for each entry of X, the corresponding polynomial piece of f (having
% first converted to ppform, if need be), and then go through the above
% process. However, that requires some management and, probably, some explicit
% process of evaluation while, at present, it's a matter of making maximal use
% of the existing commands, at the expense of cycles and memory.

form = f.form;
if length(form)>1&&isequal(form(1:2),'st')
   error('SPLINES:FNTLR:notforst','Cannot handle functions in stform.')
end
% retain f's form, but convert to ppform 
if ~isequal(form,'pp'), f = fn2fm(f,'pp'); end

m = length(dorder); k = fnbrk(f,'order');
if m~=length(k)
   error('SPLINES:FNTLR:wrongsizeDORDER', ...
         'DORDER must have as many entries as F has arguments.'),
end
if nargin>3  % check that both X and INTERV are of the correct size
   sizex = size(x);
   if length(sizex)~=2||any(sizex-[m,1])
      error('SPLINES:FNTLR:wrongsizex',['X must be of size [',num2str(m),',1].'])
   end
   if ~iscell(interv) % convert to cell, if possible
      sizei = size(interv);
      if any(sizei-[m,2])
         error('SPLINES:FNTLR:wrongsizeinterv', ...
	      ['INTERV must be of size [',num2str(m),',2].'])
      end
      interv = num2cell(interv,2);
   end
   if length(interv)~=2
      error('SPLINES:FNTLR:notenoughinterv', ...
           ['INTERV must be contain ',num2str(m),' intervals.'])
   end
end

eyem = eye(m); proddor = prod(dorder);

[breaks,l,sizeval] = fnbrk(f,'breaks','pieces','dim');  lk = prod(l)*prod(k);
ldotk = l.*k; d = sizeval; dd = prod(sizeval);

for j=1:m
   if dorder(j)>1
      coefs = reshape(fnbrk(f,'coefs'),dd,lk); ss = f;
      for i=2:dorder(j)
         ss = fndir(ss,eyem(:,j));
         coefs = [coefs; reshape(fnbrk(ss,'coefs'),dd,lk)];
      end
      dd = dd*dorder(j); 
      if iscell(breaks), f = ppmak(breaks,reshape(coefs,[dd ldotk]));
      else,              f = ppmak(breaks,reshape(coefs,dd*l,k),dd);
      end
   end
end

taylor = fnval(f,x);

if form(1)=='r'  % we now have to convert this all to the values of the
                 % corresponding rational spline. In this case, we have in
        % hand, for each x, the Taylor matrix at x of order DORDER, of the
        % function [s;w], and want, instead, that matrix for the function 
        % r : = s/w , i.e., s = wr. Hence, by Leibniz' formula,
        % D^a s = sum_{j\le a} (a choose j) D^{a-j} w D^j r ,
        % and this permits the inductive calculation of D^a r from D^a s and
        % D^{a-j} w  and D^j r  for  j<a.

   if length(dorder)>2
      warning('SPLINES:FNTLR:onlyonortw', ...
              'Can only handle univariate or bivariate rationals at present.')
      return
   end

   if m>1 % x is expected to be a matrix, of size [m,lx]
      if iscell(x), error('SPLINES:FNTLR:nogrid','Cannot handle grids.'), end
      [ignored,nx] = size(x); mx = 1;
   else
      [mx,nx] = size(x);
   end
   lx = mx*nx;

    taylor = reshape(taylor,d,proddor*lx);
   d = d-1;   
   w = reshape(repmat(taylor(d+1,:),d,1),[d,dorder,lx]); 
   taylor(d+1,:) = []; taylor = reshape(taylor,[d,dorder,lx]);

   ch = pascal(max(dorder));
         % pascal(n) is the n-th order matrix with (i,j)-entry equal to 
         % (i-1 + j-1)!/( (i-1)! (j-1)! );

   if m==1 % the univariate case

      for j=1:dorder
         taylor(:,j,:) = taylor(:,j,:)./w(:,1,:);
         for i=j+1:dorder
            taylor(:,i,:) = taylor(:,i,:) - ...
                               ch(i,j)*taylor(:,j,:).*w(:,i+1-j,:);
         end
      end

   else   % we must be in the bivariate case (eventually, remove some loops!)

      for j2=1:dorder(2)

            % finish off the j2-th column
         for j1=1:dorder(1)

            taylor(:,j1,j2,:) = taylor(:,j1,j2,:)./w(:,1,1,:);
            for i1=j1+1:dorder(1)
               taylor(:,i1,j2,:) = taylor(:,i1,j2,:) - ...
                       ch(i1,j1)*taylor(:,j1,j2,:).*w(:,i1+1-j1,j2,:);
            end
         end

            % then use each entry of the current column to modify appropriately
            % all entries to the right and below.
         for i2=j2+1:dorder(2)
            for j1=1:dorder(1)
               for i1=j1:dorder(1)
               taylor(:,i1,i2,:) = taylor(:,i1,i2,:) - ...
                      ch(i2,j2)*ch(i1,j1)*taylor(:,i1,j2,:).* ...
                                                    w(:,i1+1-j1,i2+1-j2,:);
               end
            end
         end
      end 
   
   end

   taylor = reshape(taylor, [d*proddor*mx,nx]);
end

if nargin>3

   taylor = reshape(taylor,[d,dorder]); maxdorder = max(dorder);
   facts = reshape(repmat(1./[1,cumprod(1:maxdorder-1)],d,1),d*maxdorder,1);
   
   breaks = cell(1,m);
   for j=1:m
      for i=3:dorder(m)
         taylor(:,i,:) = facts(i)*taylor(:,i,:);
      end
      taylor = permute(taylor(:,dorder(j):-1:1,:),[1,3:m+1,2]);
      breaks{j} = [x(j),x(j)+diff(interv{j})];
   end
   out = fnbrk(ppmak(breaks,taylor),interv);
   if length(sizeval)>1, out = fnchg(out,'dz',sizeval); end
else
   out = taylor;
end
