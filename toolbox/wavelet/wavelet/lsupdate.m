function y = lsupdate(option,x,F,DF,S,LStype)
%LSUPDATE Compute lifting scheme update.
%   For a vector X, Y = LSUPDATE('v',X,F,DF,SY) returns 
%   a vector Y which length is SY. X is filtered by the
%   vector F with a delay of DF.
%   
%   For a matrix X, Y = LSUPDATE('r',X,...) computes the "update"
%   of X rowwise, like in the vector option. Y = LSUPDATE('c',X,...)
%   computes the "update" of X columnwise. In that cases, SY is
%   the size of the matrix Y.
%
%   Y = LSUPDATE(...,INT_FLAG) returns integer values (fix). 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-2001.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:56 $

lF = length(F);
sx = size(x);
y  = zeros(sx);
switch option
  case 'v'
      lx = length(x);
      for j=1:lF
          t = F(j)*x;
          k = DF-j+1; 
          if     k>0 , t = t(1+k:end); t(end+k)= 0;
          elseif k<0 , t(1-k:end) = t(1:end+k); t(1:-k) = 0;
          end
          y = y + t(1:lx);
      end
      d = S-lx;
      if d>0 , y(end+d) = 0; elseif d<0 , y = y(1:S); end
    
  case 'r'
      for j=1:lF
          k = DF-j+1; 
          t = F(j)*x;
          if     k>0 , t = t(:,1+k:end); t(:,end+k)= 0;
          elseif k<0 , t(:,1-k:end) = t(:,1:end+k); t(:,1:-k) = 0;
          end
          y = y + t(:,1:sx(2));
      end
      d = S(2)-sx(2);
      if d>0 , y(:,end+d) = 0; elseif d<0 , y = y(:,1:S(2)); end

  case 'c'
      for j=1:lF
          k = DF-j+1; 
          t = F(j)*x;
          if     k>0 , t = t(1+k:end,:); t(end+k,:)= 0;
          elseif k<0 , t(1-k:end,:) = t(1:end+k,:); t(1:-k,:) = 0;
          end
          y = y + t(1:sx(1),:);
      end
      d = S(1)-sx(1);
      if d>0 , y(end+d,:) = 0; elseif d<0 , y = y(1:S(1),:); end
end

if ~isempty(LStype) , y = fix(y); end
