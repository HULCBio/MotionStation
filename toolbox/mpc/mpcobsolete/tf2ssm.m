function [a,b,c,d] = tf2ssm(num,den)
%TF2SSM	Construct a SS realization of a transfer function
%	[A,B,C,D] = tf2ssm(Num, Den)
%
%       Y(s) = H(s)u(s)
%       H(s) = Num(s)/Den(s)
%       Y(s) may Contain More than one Output so Num(s) may contain
%       more than one row.
%       u(s) is scalar (due to MATLAB limitations)
%       Den(s) is the common denominator of all h(s)
%
%       The Realization is :
%                x(k+1) = A*x(k) + B*u(k)
%                y(k)   = C*x(k) + D*u(k)
%

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% First make numerator and denominator same order.  Then
% reduce order by removing leading denominator zeros (if possible).

if all(den == 0)
   error('Denominator must be non-zero')
elseif isempty(den) | isempty(num)
   error('NUM or DEN is an empty matrix')
end
[mden,n]=size(den);
if mden > 1
   error('DEN has more than 1 row')
end
[ny,ncol]=size(num);
if ncol < n
   num=[zeros(ny,n-ncol) num];    % pad numerator if necessary
end
inz = find(den ~= 0);
den = den(inz(1):n);
[mden,n] = size(den);
nextra=ncol-n;
while nextra > 0
   if any(num(:,1) > 0)
      error('Order of numerator greater than denominator')
   end
   num(:,1)=[];
   nextra=nextra-1;
end
num=num/den(1);
den=den/den(1);

n2=length(den);

if n2 == 1

%        Handle special constant case

   a = [];
   b = zeros(0,1);
   c = zeros(ny,0);
   d = num(:,1);

else

%		General case

   for i = 1:ny
      [d(i,1),e(i,:)] = deconv(num(i,:),den);
      [nrow,ncol]=size(e);
      c(i,:) = e(i,2:ncol);
   end

   a = [-den(2:n2);eye(n2-2) zeros(n2-2,1)];
   b = [1;zeros(n2-2,1)];

end