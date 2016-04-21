function a = idnamchk(a,Name)
%IDNAMCHK Checks channel, state and parameter names

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:57 $

% Checks specified I/O names
if isempty(a),  
   a = a(:);   % make 0x1
   return  
end

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) & ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
   
elseif iscellstr(a) & ndims(a)==2 & min(size(a))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun('ndims',a)>2) | any(cellfun('size',a,1)>1),
      error(sprintf('All cell entries of %s must be single-line strings.',Name))
   end
   
else
   error(sprintf('%s %s\n%s',Name,...
      'must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
      'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'))
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
if any(repeat),
   % Be forgiving for default state-names
   if strcmp(lower(Name),'statename')&all(as(:,1)=='x')
      a = defnum([],'x',length(as));
   else
      error(sprintf('%s: channel names must be unique.',Name))
   end
end
