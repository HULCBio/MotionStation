function tf = ismembererr(a,s,flag,err)
% ISMEMBERERR true for set member taking into account floating point errors

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:19:33 $

error(nargchk(2,4,nargin));

if nargin<4,  err = 0;  end
if nargin<3,  flag = 'none';  end

if isempty(flag) | strcmp(flag,'none')

  s = double(s);
  if (isreal(s))
    s = sort(s(:));
  else
    [junk,idx] = sort(real(s(:)));
    s = s(idx);
  end

  na = length(a(:));  ns = length(s(:));
  A = reshape(reshape(repmat(a(:),ns,1),na,ns)',na*ns,1);
  S = repmat(s(:),na,1);
  indx = find( (abs(A-S)>=0 & abs(A-S)<=err) );
  [i,j] = ind2sub(size(a),ceil(indx/ns));
  tf = logical(zeros(size(a)));
  tf(i,j) = 1;

elseif strcmp(flag,'rows')

  na = length(a(:,1));  ns = length(s(:,1));
  A = reshape(repmat(a,1,ns)',2,na*ns)';
  S = repmat(s,na,1);
  indx = find(all((abs(A-S)>=0 & abs(A-S)<=err)',1)');
  idx = ceil(indx/ns);
  tf = logical(zeros(size(a(:,1))));
  tf(idx) = 1;

end
