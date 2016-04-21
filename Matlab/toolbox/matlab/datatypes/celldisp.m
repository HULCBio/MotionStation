function celldisp(c,s)
%CELLDISP Display cell array contents.
%   CELLDISP(C) recursively displays the contents of a cell array.
%
%   CELLDISP(C,NAME) uses the string NAME for the display instead of the
%   name of the first input (or 'ans').
%
%   See also CELLPLOT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.1 $  $Date: 2004/01/26 23:20:43 $

error(nargchk(1,2,nargin));
if ~iscell(c),
  error('MATLAB:celldisp:notCellArray', 'Must be a cell array.');
end

isloose = strcmp(get(0,'formatspacing'),'loose');

if nargin==1, s = inputname(1); end
if isempty(s), s = 'ans'; end

for i=1:numel(c),
  if iscell(c{i}) && ~isempty(c{i}),
     celldisp(c{i},[s subs(i,size(c))])
  else
    if isloose, disp(' '), end
    disp([s subs(i,size(c)) ' ='])
    if isloose, disp(' '), end
    if ~isempty(c{i}),
      disp(c{i})
    else
      if iscell(c{i})
        disp('     {}')
      elseif ischar(c{i})
        disp('     ''''')
      elseif isnumeric(c{i})
        disp('     []')
      else
        [m,n] = size(c{i});
        disp(sprintf('%0.f-by-%0.f %s',m,n,class(c{i})))
      end
    end
    if isloose, disp(' '), end
  end
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = subs(i,siz)
%SUBS Display subscripts

if length(siz)==2 & any(siz==1),
  v = cell(1,1);
else
  v = cell(size(siz));
end
[v{1:end}] = ind2sub(siz,i);

s = ['{' int2str(v{1})];
for i=2:length(v),
  s = [s ',' int2str(v{i})];
end
s = [s '}'];
