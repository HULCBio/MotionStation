function status = dpsssave(NW,E,V)
%DPSSSAVE  Save discrete prolate spheroidal sequences in database.
%   DPSSSAVE(NW,E,V) saves the DPSSs in E and their concentrations V in the
%   DPSS MAT-file database, 'dpss.mat'.  The length N of the DPSSs is determined
%   by the number of rows of E, and NW is the "time-bandwidth product".
%
%   STATUS = DPSSSAVE(NW,E,V) returns 0 if the save was successful and 1 if
%   there was some error.
%
%   See also DPSS, DPSSLOAD, DPSSDIR, DPSSCLEAR.

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $

error(nargchk(3,3,nargin))
stat = 0;
w = which('dpss.mat','-all');
N = size(E,1);

if ~all(size(NW)==1) | NW<0
    error('The first input must be a scalar time-bandwidth product.')
end
if size(E,2) ~= length(V)
    error('Number of columns of E and length of V do not match.')
end

doubled = 0;
if iscell(w)
    for i=1:length(w)
        doubled = strcmp(w{1},w{i});
        if doubled, break, end
    end
end

if ~doubled & length(w)>1
    warning(sprintf('Multiple dpss.mat files found on path, using %s.',w{1}))
end

if length(w) == 0      % new dpss database
    w = 'dpss.mat';
    index.N = N;
    index.wlist.NW = NW;
    index.wlist.key = 1;
  
    this_key = 1;
    next_key = 2;
    app = '';
else     % add this to existing dpss
    w = w{1};
    %eval(['load ' w ' index next_key'])
    %eval(['load(''' w ''', ''index'', ''next_key'')'])
    load(w, 'index', 'next_key');
    
    this_key = next_key;
    next_key = next_key + 1;

    index1 = dpssdir(N,NW);
    i = find([index.N]==N);
    if ~isempty(index1),
        disp('dpss.mat already contains this E and V; over-writing old values.')
        this_key = index1.wlist.key;
        next_key = next_key - 1;
    elseif ~isempty(i)
        index(i).wlist(end+1).NW = NW;
        index(i).wlist(end).key = this_key;
    else
        index(end+1).N = N;   % grow index by 1
        index(end).wlist.NW = NW;
        index(end).wlist.key = this_key;
    end

    app = '-append';
end

copystr = sprintf('E%g = E; V%g = V;',this_key,this_key);
eval(copystr,'stat=1;')

if ~stat
    if isempty(app)
        appstr = ')';
    else
        appstr = [',''' app ''')'];
    end
    savestr = sprintf(['save(''%s'',''index'', ''next_key'', ''E%g'', '...
                 '''V%g''' appstr],...
                 w,this_key,this_key);
    eval(savestr,'stat=1;')
end

if nargout > 0
    status = stat;
end
