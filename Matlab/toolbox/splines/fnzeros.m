function z = fnzeros(f,interv)
%FNZEROS zeros of a function (in a given interval)
%
%   Z = FNZEROS(F) or FNZEROS(F,[]) returns an ordered list of the zeros
%   of the continuous univariate spline in F in its basic interval.
%
%   Z = FNZEROS(F,INTERV) only looks for zeros in the interval specified
%   by INTERV (as [a,b]).
%
%   Each column Z(:,j) in the 2-by-n matrix Z contains the left and right
%   endpoint of an interval. These intervals are of three kinds:
%   (i) the endpoints agree; in that case, the function in F is relatively
%     small at that point.
%   (ii) the endpoints agree to many significant digits; in that case, the
%     function changes sign across that interval, hence the interval contains
%     a zero of the function provided the function is continuous there.
%   (iii) the endpoints are not close; in that case, the function is zero
%     on the entire interval.
%
%   Examples:
%   The quadratic polynomial (x-1)^2 =x^2-2*x+1  has a double zero at x = 1;
%   correspondingly, the command
%
%      fnzeros(ppmak([0 2.1],[1 -2 1]))
%
%    returns a matrix that is nearly ones(2,2). Also,
%
%      f = spmak(1:21,rand(1,15)-.5); interv = fnbrk(f,'in');
%      min( fnval(f, [interv,mean(fnzeros(fnder(f),interv))] ) )
%
%   returns the minimum value of the univariate scalar function in  f
%   on its basic interval.
%
%   See also FNVAL, FNMIN.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2003/04/25 21:12:19 $

if fnbrk(f,'var')>1
   error('SPLINES:FNZEROS:onlyuni','This only works for univariate functions.'), end

if nargin>1&&~isempty(interv), f = fnbrk(f,interv); end

d = fnbrk(f,'dim');
if length(d)>1||d>1
   error('SPLINES:FNZEROS:onlyscalar', ...
         'At present, this only works for scalar-valued functions.')
end

f = fn2fm(f,'B-'); % make sure the function is in B-form

[k,coefs] = fnbrk(f,'order','coefs');
if size(coefs,1)>1     %  since f is scalar-valued, it must be rational;
   coefs = coefs(1,:); %  so, look only at the numerator.
end

   % deal directly with the special case that f is the zero function
if ~any(coefs), z = fnbrk(f,'interv').'; return, end

   %  ... or that f is of constant sign
scoefs = sign(coefs);
if all(scoefs>0)||all(scoefs<0), z = zeros(2,0); return, end

knots = fnbrk(f,'knots');
   % Deal with the fact that, if F is in B-form, then it may vanish at the
   % endpoints of its basic interval without having zero coefficients there.
if scoefs(1)&&~fnval(f,knots(1))
   knots = knots([1,1:end]); scoefs = [0,scoefs]; end
if scoefs(end)&&~fnval(f,knots(end))
   knots = knots([1:end,end]); scoefs = [scoefs,0]; end

   % deal with coefficients that are zero:
mults = knt2mlt(cumsum(abs(scoefs)));
   % for all j>1 and all 0<=r<mults(j), scoefs(j-r)==0, hence each entry of
temp = find(diff(mults)<0); if ~scoefs(end), temp = [temp length(coefs)]; end
   % indicates the end of a run of consecutive zeros.
zints = zeros(2,0);
% check for an initial zero
if ~scoefs(1)
   lastz = 2; if ~scoefs(2), lastz = temp(1)+1; temp(1)=[]; end
   zints = knots([1 lastz]).';
   scoefs(1:lastz-1) = scoefs(lastz);
end
if ~isempty(temp)
   % check for a final zero, but store it separately first, to keep order
   if ~scoefs(end)
      zfinal = knots([end-mults(end) end]).'; temp(end)=[];
      scoefs(end-mults(end)+1:end) = scoefs(end-mults(end));
   end
   % deal with zero intervals, if any:
   ints = find(mults(temp)>k-2);
   if ~isempty(ints)
      zints = ...
       [zints [knots(temp(ints)-mults(temp(ints))+k);knots(temp(ints)+1)]];
   end
   % fill in the other zero coefficients as one of the bordering
   % coefficients, to generate a search point only if there is a sign change
   % across that string of zeros.
   outs = 1:length(temp); outs(ints)=[];
   for j=outs
      scoefs(temp(outs)+1-mults(temp(outs)):temp(outs)) = -scoefs(temp(outs)+1);
   end
   if exist('zfinal','var'), zints = [zints zfinal]; end
end
   % At this point, the only coefficients still zero span an entire zero
   % interval; no need to search for a zero at their edges.
   % So, look for sign changes, i.e., abs(diff(scoefs))>1

sc = find(abs(diff(scoefs))>1);
if isempty(sc)
   z = zints; return
end

if k<2 % f is a piecewise constant, hence the sign changes occur at knots:
   z = knots([1 1],sc+1);
   if ~isempty(zints)
      z = [zints z]; [ignore, ii] = sort(z(1,:)); z = z(:,ii); end
   return
end

dsc = diff(sc); tooclose = find(dsc<k-1);
while ~isempty(tooclose)
   % separate the zeros; do this by inserting enough knots between the
   % relevant knot averages to make certain that sc(i)+k<=sc(i+1):
   aveknots = aveknt(fnbrk(f,'knots'),k);
   f = fnrfn(f, brk2knt(...
      (aveknots(sc(tooclose))+aveknots(sc(tooclose+1)))/2, ...
      k-1-dsc(tooclose)));
   sc = find(diff(fix((sign(fnbrk(f,'coefs'))+1)/2))~=0);
   dsc = diff(sc); tooclose = find(dsc<k-1);
end

nz = length(sc); z = zeros(2,nz); [knots, coefs, n] = spbrk(f);
for j=1:nz
   z(:,j) = mrf(@fnval,knots(sc(j)+[1,k]), ...
          max(abs(coefs(max(1,sc(j)+2-k):min(n,sc(j)+k-1))))*1e-15, f);
end
z(:,isnan(z(1,:)))=[];

if ~isempty(zints)
   z = [zints z]; [ignore, ii] = sort(z(1,:)); z = z(:,ii); end

function z = mrf(f,ab,ftol,argf)
%MRF sign change of f in [a .. b] via modified regula falsi

% construct xtol
a = ab(1); b = ab(2); xtol = max(abs(ab))*1e-13;

fab = feval(f,ab,argf);
fa = fab(1); if ~fa, z = [a;a]; return, end
fb = fab(2); if ~fb, z = [b;b]; return, end

signfb = sign(fb);
if signfb==sign(fa), z = [NaN;NaN]; return, end

for j=1:20
   bma = b-a;
   if abs(bma)<=xtol, break, end
   z = b - fb/(fb-fa)*bma; fz = feval(f,z,argf);
   if abs(fz)<ftol, a = z; b = z; break, end
   if sign(fz)==signfb
      fa = fa/2;
   else
      a = b; fa = fb; signfb = -signfb;
   end
   b = z; fb = fz;
end

z = [a;b];

