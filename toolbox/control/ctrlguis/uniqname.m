function s1 = uniqname(s0);
%UNIQNAME determines the shortest unique value for each name in a set
%   UNIQNAME(Names) looks through the cell array of Simulink block
%   names provided in Names and determines the shorts string that
%   uniquely represents each block. These names are then used as
%   the state, input, and output names in the linearized model
%   obtained in LINSUB.

%   Greg Wolodkin, 7-23-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 04:42:43 $

% Starting with a cell array of Simulink block names,
% remove newlines and as many system/subsystem names
% as possible from each entry such that the list of
% names is still unique

N = length(s0);

if isequal(N,0),
   s1=s0;
   return
end

% Strip out newlines
s1 = strrep(s0,sprintf('\n'),'');

% Sort so that we can unsort later
[stmp,ox] = sort(s1);
[junk,px] = sort(ox);

% Some names may be identical (any block with more than one state..)
% In that case, use (1), (2), etc. to differentiate them.
[xx,ix,jx] = unique(stmp);
for k=1:N
  if jx(k) > 0
    kx = find(jx==jx(k));
    if length(kx) > 1 
      for n=1:length(kx)
        stmp{kx(n)} = [stmp{kx(n)} '(' int2str(n) ')'];
      end
      jx(kx) = zeros(size(kx));
    end
  end
end
stmp = stmp(px,1);			% undo the first sort

% Now start stripping subsystem names
done = 0;
umask = Inf*ones(N,1);

while ~done
  for k=1:N
    if umask(k) ~= 0
      xx = findstr(stmp{k},'/');
      umask(k) = min(length(xx), umask(k));
      s1{k} = stmp{k}(xx(umask(k))+1:end); 
    else
      s1{k} = stmp{k};
    end
  end

  % Sort so that we can unsort later
  [s2,ox] = sort(s1);
  [junk,px] = sort(ox);

  % build the next umask
  [xx,ix,jx] = unique(s2);
  if length(xx) == N		 	% already unique
    done = 1;
  else
    for k=1:N
      if jx(k) > 0
        kx = find(jx==jx(k));
        if length(kx) > 1 
          umask(ox(kx)) = umask(ox(kx)) - 1;
        end
        jx(kx) = zeros(size(kx));
      end
    end
  end
end
s1 = s2(px);


