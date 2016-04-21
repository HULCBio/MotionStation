% called by LMIINFO

% Author: A. Ignat  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function infobw(LMI_set,LMI_var,LMI_term,data,nr_lmi,rlinf,inflmi)

if inflmi == 'b' | inflmi == 'B',   % block info

  disp(' ');
  ind = goodans(1,LMI_set(6,nr_lmi),' Enter the block coordinates ',2) ;
  iab = 1 ; ic = 1 ;
  [writevar,iab,ic] = blckcont(LMI_var,LMI_term,data,LMI_set(1,nr_lmi),...
                               rlinf,ind(1),ind(2),iab,ic) ;
  if isempty(dblnk(writevar)), writevar=' 0'; end

  disp(sprintf(' This block is of the form \n'));
  disp(sprintf('      %s\n\n',writevar)) ;

elseif inflmi == 'w' | inflmi == 'W',  % info about the whole LMI

  if rlinf == 'r' | rlinf == 'R', writevar = ['Right'];
  else writevar = ['Left']; end
  disp(sprintf('\n %s inner factor: \n ',writevar));
  iab = 1 ; ic = 1;

  % structure of all diagonal and sub-diagonal blocks

  for i = 1:LMI_set(6,nr_lmi),
    for j = 1:i
      [writevar,iab,ic] = blckcont(LMI_var,LMI_term,data,...
                                   LMI_set(1,nr_lmi),rlinf,i,j,iab,ic) ;
      if isempty(dblnk(writevar)), writevar=' 0'; end
      disp(sprintf('    block (%i,%i): %s \n',i,j,writevar));
    end
  end
  disp(' ');

end % if inflmi
