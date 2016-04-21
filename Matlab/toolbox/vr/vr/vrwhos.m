function vrwhos
%VRWHOS List all virtual worlds in memory, long form.
%   VRWHOS is a long form of VRWHO. It lists all virtual worlds currently
%   in memory, together with detailed information about them.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2003/01/12 22:41:36 $ $Author: batserve $

ww = vrwho;
for i= 1:numel(ww)
  w = ww(i);

  fprintf('\n\t%s\n', get(w,'Description'));

  opencnt = get(w,'OpenCount');
  clients = get(w,'Clients');
  filename = get(w,'FileName');

  switch opencnt
    case 0
      fprintf('\t\tClosed, associated with ''%s''.\n', filename);
    case 1
      fprintf('\t\tLoaded from ''%s'' (open once).\n', filename);
    otherwise
      fprintf('\t\tLoaded from ''%s'' (open %d times).\n', filename, opencnt);
  end

  if strcmpi(get(w, 'View'), 'on')
    if strcmpi(get(w, 'RemoteView'), 'on')
      fprintf('\t\tVisible for all viewers.\n');
    else
      fprintf('\t\tVisible for local viewers.\n');
    end
  else
    fprintf('\t\tNot visible.\n');
  end

  switch clients
    case 0
      fprintf('\t\tNo clients are logged on.\n');
    case 1
      fprintf('\t\t1 client is logged on.\n');
    otherwise
      fprintf('\t\t%d clients are logged on.\n', clients);
  end

end
