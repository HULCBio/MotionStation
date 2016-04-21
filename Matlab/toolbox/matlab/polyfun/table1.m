function y = table1(tab,x0)
%TABLE1 1-D Table look-up.
%   Y = TABLE1(TAB,X0) returns a table of linearly interpolated rows
%   from table TAB, looking up X0 in the first column of TAB.  TAB is
%   a matrix that contains key values in its first column and data in
%   the remaining columns.  One interpolated row from TAB will be
%   returned for each element in X0.  The first column of TAB must be
%   monotonic.
%
%   Example:
%      tab = [(1:4)' magic(4)];
%      y = table1(tab,1:4);
%   is an expensive way to produce y = magic(4);
%
%   The TABLE1 function is OBSOLETE, use INTERP1 or INTERP1Q instead.
%
%   See also INTERP1, INTERP2, TABLE2.

%   Different algorithms are used depending on whether X0 is scalar
%   so that vectorization can be exploited in the case of vector X0.
%   It is an error to request a value outside the range of the first
%   column of TAB for X0.


%   Tomas Schoenthal 5-1-85
%   Egbert Kankeleit 1-15-87
%   Revised by L. Shure 2-3-87
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.13 $  $Date: 2002/04/15 04:26:00 $

warning('MATLAB:table1:ObsoleteFunction',['TABLE1 is obsolete and ' ...
            'will be removed in future versions.  Use INTERP1 or ' ...
            'INTERP1Q instead.'])

if (nargin ~= 2), error('Wrong number of input arguments.'), end

[m,n]=size(tab);
k0=length(x0);
if m<2, error('TAB must have at least 2 rows.'); end

if k0==1
   dx=tab(2:m,1)-tab(1:m-1,1);
   sig=sign(dx(1,1));
   if any(sign(dx(:))-sig);
   error('First column of the table must be monotonic.')
   end
   if sig > 0
        ii = find(tab(:,1) >= x0);
        if isempty(ii), error('x0 larger than all values in first column'); end
        if x0 < tab(1,1)
           error('x0 smaller than all values in first column') 
        end
   else
   ii = find(tab(:,1) <= x0);
        if isempty(ii),
           error('x0 smaller than all values in first column')
        end
        if x0 > tab(1,1)
           error('x0 larger than all values in first column')
        end
   end
   kk=ii(1);
   xhigh = tab(kk,1);
   if kk > 1 
      xlow = tab(kk-1,1);
   else
      xlow = xhigh;
   end
   if xlow == xhigh
      y = tab(kk,:);
   else
      alpha = (xhigh-x0)/(xhigh-xlow);
      beta = 1. - alpha;
      y = alpha*tab(kk-1,:) + beta*tab(kk,:);
   end
   y = y(2:n);
   return
else
   dx=tab(2:m,:)-tab(1:m-1,:);
   dx=[dx;dx(m-1,:)];sig=sign(dx(1,1));
   if any(sign(dx(:,1))-sig);
   error('First column of the table must be monotonic.')
   end
   y=zeros(k0,n-1);
   for k=1:k0
     if sig>0; ii=max(find(tab(:,1) <= x0(k) ));
        if isempty(ii), error('x0 smaller than all values in first column'); end
        if x0(k) > tab(m,1)
           error('x0 larger than all values in first column') 
        end
     else ; ii=max(find(tab(:,1) >= x0(k) ));
        if isempty(ii),
           error('x0 larger than all values in first column')
        end
        if x0(k) < tab(m,1)
           error('x0 smaller than all values in first column')
        end
     end
     y(k,:)=tab(ii,2:n)+dx(ii,2:n)*(x0(k)-tab(ii,1))/dx(ii,1);
   end
end
