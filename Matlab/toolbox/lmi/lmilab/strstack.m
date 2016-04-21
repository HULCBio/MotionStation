% called by PARSLMI

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function strmat=strstack(strmat,str)

rs=size(strmat,1);
if rs==0, strmat = '';  end

if ~isempty(str),
  strmat(rs+1:rs+size(str,1),1:size(str,2))=str;
end

