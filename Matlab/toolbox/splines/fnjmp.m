function jumps = fnjmp(f,x)
%FNJMP Jumps, i.e., f(x+) - f(x-) .
%
%   JUMPS = FNJMP(F,X)  is like FNVAL(F,X), except that the jump
%    f(X+) - f(X-)  across X (rather than the value  f(X)  at X) for the
%   function  f  specified by F is returned. Also,  f  must be univariate pp.
%
%   Example:
%      fnjmp( ppmak( 1:4 , 1:3), 1:4 ) 
%   returns the vector [ 0, 1, 1, 0]  (since the function here is in ppform,
%   and is piecewise constant, 
%   has the value 1 on the interval [1,2], 
%   has the value 2 on the interval [2,3], 
%   has the value 3 on the interval [3,4], 
%   hence has zero jump at 1 and 4 and a jump of 1 across both 2 and 3).

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.17 $

if ~isstruct(f), f = fn2fm(f); end

if fnbrk(f,'var')>1||isequal(f.form(1:2),'st')
   error('SPLINES:FNJMP:onlyuni',...
   'FNJMP only works with univariate pp functions.'), end

%   for simplicity, deal with ND-valued functions by making them vector-valued
sizeval = fnbrk(f,'dim'); d = sizeval;
if length(sizeval)>1, d = prod(sizeval); f = fnchg(f,'dz',d); end

%  If necessary, convert x to matrix and sort:
sizex = size(x);
if length(sizex)>2
   x = reshape(x,sizex(1),prod(sizex(2:end)));
elseif length(sizex)==2&&sizex(1)==1, sizex = sizex(2); end

[mx,nx] = size(x); lx = mx*nx; xs = reshape(x,1,lx);
jumps = zeros(d,lx);

tosort = 0;
if any(diff(xs)<0)
   tosort = 1; [xs,ix] = sort(xs);
end

form = f.form;
switch form
case {'B-','BB','rB'}
   if form(1)=='r', f = fn2fm(f,'B-'); end
   [t,a,n,k,df] = spbrk(f);

   indexr = sorted(t,xs); indexl = n+k - sorted(-t,-xs);
   indexl = indexl(lx:-1:1);
   index = find(indexr-indexl>=k);
   if ~isempty(index)
      if form(1)=='B'
         a = [zeros(df,1) a zeros(df,1)];
         jumps(:,index) = a(:,indexr(index)+2-k) - a(:,indexl(index)+1);
      else
         a = [zeros(df,1) a zeros(df,1)];
         jumps(:,index) = ratjump(a(:,indexr(index)+2-k),a(:,indexl(index)+1));
      end
   end
case {'pp','rp'}
   if form(1)=='r', f = fn2fm(f,'pp'); end
   [breaks,l] = ppbrk(f,'breaks','pieces');

   if l==1
      jumps = zeros(d*mx,nx);
   else
      index = sorted(breaks(2:l+1),xs); cands = find(index>0&index<l);
      index1 = find(xs(cands)-breaks(index(cands)+1)==0);
      if ~isempty(index1)
         index = cands(index1);
         if form(1)=='p'
            jumps(:,index) = ppual(f,xs(index)) - ppual(f,xs(index),'left');
         else
            jumps(:,index) = ...
	              ratjump(ppual(f,xs(index)),ppual(f,xs(index),'left'));
         end
      end
   end
otherwise
   error('SPLINES:FNJMP:unknownfn','The form of F is not (yet) recognized.')
end

if tosort>0,  jumps(:,ix) = jumps; end

jumps = reshape(jumps,[sizeval,sizex]);

function jumps = ratjump(vplus,vminus)
%RATJUMP Compute jump in rational function s/w from the values of [s;w] .

d = size(vplus,1)-1;
jumps = (vplus(1:d,:).*repmat(vminus(d+1,:),d,1) ...
         -vminus(1:d,:).*repmat(vplus(d+1,:),d,1))./ ...
                          repmat(vplus(d+1,:).*vminus(d+1,:),d,1);
