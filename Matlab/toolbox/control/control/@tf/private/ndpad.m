function [num,den] = ndpad(num,den,var)
%NDPAD  Pads the numerators or denominators of Transfer Functions
%       with zeros to make NUM{i,j} and DEN{i,j} of equal length.  
%       The zeros are added to the left if  VAR = 's' or 'z'  and 
%       to the right otherwise.
%
%       NDPAD also removes the extra leading zeros in NUM{i,j} and 
%       DEN{i,j} (while keeping them of equal length)

%      Author: P. Gahinet, 5-1-96
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.10 $  $Date: 2002/04/10 06:08:55 $


if strcmp(var,'z^-1') | strcmp(var,'q'),
   for k = 1:prod(size(num)),
      nk = num{k};    
      dk = den{k};
      % Pad zeros to the right to make num/den of equal length
      lgap = length(dk) - length(nk);
      nk = [nk , zeros(1,lgap)];
      dk = [dk , zeros(1,-lgap)];
      % Remove leading and trailing zeros appearing in both num and den 
      % (delete leading zeros to ensure that num(1) or den(1) is always nonzero)
      ind = find(nk~=0 | dk~=0);
      num{k} = nk(ind(1):ind(end));
      den{k} = dk(ind(1):ind(end));
   end
else
   for k = 1:prod(size(num)),
      nk = num{k};    
      dk = den{k};
      % Pad zeros to the left to make num/den of equal length
      lgap = length(dk) - length(nk);
      nk = [zeros(1,lgap) , nk];
      dk = [zeros(1,-lgap) , dk];
      % Remove leading zeros appearing in both num and den
      l = length(dk);
      ind = find(nk~=0 | dk~=0);
      num{k} = nk(ind(1):l);
      den{k} = dk(ind(1):l);
   end
end

