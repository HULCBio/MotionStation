function d = dpssdir(N,NW)
%DPSSDIR  Discrete prolate spheroidal sequence database directory.
%   DPSSDIR lists the directory of saved DPSSs in the file dpss.mat.
%   DPSSDIR(N) lists the DPSSs saved with length N.
%   DPSSDIR(NW,'NW') lists the DPSSs saved with time-halfbandwidth product NW.
%   DPSSDIR(N,NW) lists the DPSSs saved with length N and time-halfbandwidth 
%   product NW.
%
%   INDEX = DPSSDIR is a structure array describing the DPSS database.
%   Pass N and NW options as for the no output case to get a filtered INDEX.
%
%   See also DPSS, DPSSSAVE, DPSSLOAD, DPSSCLEAR.

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.8 $

N_FIXED = 0;
NW_FIXED = 0;

if nargin == 1
    N_FIXED = 1;
end
if nargin == 2
    if isstr(NW)
        NW_FIXED = 1;
        NW = N;
    else
        N_FIXED = 1;
        NW_FIXED = 1;
    end
end

index = [];
w = which('dpss.mat','-all');

doubled = 0;
if iscell(w)
    for i=2:length(w)
        doubled = ~strcmp(w{1},w{i});
        if doubled, break, end
    end
end

if doubled & length(w)>1
    warning(sprintf('Multiple dpss.mat files found on path, using %s.',w{1}))
end

if length(w) == 0      % new dpss database
    if nargout == 0
        disp('   Could not find dpss.mat on path or in current directory.')
    end
else     % add this to existing dpss
    w = w{1};
    load(w, 'index');
    
    if nargout == 0
        disp(sprintf('File: %s',w))
        disp('    N     NW    Variable names')
        disp('   ---   ----  ----------------')
    end
    wh = whos('-file',w);

    [Nsort,ind] = sort([index.N]);
    index = index(ind);

    if N_FIXED
        ind = find(Nsort==N);
        index = index(ind);
    end

    for i = 1:length(index)
      [wlist,ind] = sort([index(i).wlist.NW]);
      index(i).wlist = index(i).wlist(ind);
      if NW_FIXED
          ind = find(wlist==NW);
          index(i).wlist = index(i).wlist(ind);
      end
 
      if nargout == 0
          for j = 1:length(index(i).wlist)

            key = index(i).wlist(j).key;
        
            args = {index(i).wlist(j).NW, key, key};
            if j == 1
                args = {index(i).N, args{:}};
                str = sprintf('%7.0f %5.2f  E%g, V%g', args{:});
            else
                str = sprintf('        %5.2f  E%g, V%g', args{:});
            end
            disp(str)

          end
      end
      
    end
    for i = length(index):-1:1
        if length(index(i).wlist)==0
            index(i) = [];
        end
    end
    if length(index)==0 & nargout == 0
        disp('    No DPSSs found.')
    end
end
    

if nargout > 0
    d = index;
end
