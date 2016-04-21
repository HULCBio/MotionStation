function v=subsref(v,subscripts)
%SUBSREF Reference fields of a neural network.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

% Assume no error
err = 0;

% Short hand fields
type = subscripts(1).type;
subs = subscripts(1).subs;

% For each level of subscripts
for i=1:length(subscripts)

  type = subscripts(i).type;
  subs = subscripts(i).subs;
  
  switch type
  
  % Paretheses
  case '()'
    eval('v=v(subs{:});','err=1;');
  
  % Curly bracket
  case '{}'
    eval('v=v{subs{:}};','err=1;');
  
  % Dot
  case '.'
  if isa(v,'struct') | isa(v,'network')
      f = fieldnames(v);
    for i=1:length(f)
      if strcmp(subs,lower(f{i}))
        subs = f{i};
      break;
      end
    end
  end

    eval(['v=v.' subs ';'],'err=lasterr;');
  
  end
  
  % Error message
  if err
    errmsg = lasterr;
 
   % Work around: remove any reference to variable V
   ind = findstr(errmsg,' ''v''');
    if (ind)
      errmsg(ind+[0:3]) = [];
    end
  
  error(errmsg)
  end
end

