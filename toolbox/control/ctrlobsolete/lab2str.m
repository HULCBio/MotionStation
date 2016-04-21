function labels=lab2str(ulab)
%LAB2STR Compact and convert labels in string line or matrix.

%   Clay M. Thompson 8-20-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:17 $

len = 12; % Label length parameter

[m,n] = size(ulab);

if m==1,
  % Put labels into format for PRINTMAT

  % First remove extra spaces (delimiters)
  delim = (ulab==' '); ndx = find([delim,0]&[0,delim]);
  if ~isempty(ulab), ulab(ndx) = []; end
  labels = ulab;

else 
  % Convert labels from SIMULINK
  labels = [];
  for i=1:m,
    j = n;
    while (ulab(i,j)~='/')&(j>1), j=j-1; end
    if ulab(i,j)~='/', lab = ulab(i,j); else lab = []; end
    while (ulab(i,j)~=' ')&(j<n), j=j+1; lab = [lab,ulab(i,j)]; end
    labels = [labels,lab,' '];
  end

end

% end lab2str
