function [bp,wf]=ncrule(m)
%usage:  [bp,wf]=ncrule(m);
%  This function returns the Newton-Coates base points and weight factors
%  up to an 8 point Newton-Coates formula.
%
%  m -- number of Newton-Coates points (integrates an mth order
%       polynomial exactly (or an (m+1)th order for even m))

%  By Bryce Gardner, Purdue University, Spring 1993.

if ( m == 1 )
  bp=[-1;1];
  wf=[1;1];
elseif ( m == 2 )
  bp=[-1;0;1];
  wf=[1;4;1]/3;
elseif ( m == 3 )
  bp=[-1;-1/3;1/3;1];
  wf=[1;3;3;1]/4;
elseif ( m == 4 )
  bp=[-1;-1/2;0;1/2;1];
  wf=[7;32;12;32;7]/45;
elseif ( m == 5 )
  bp=[-1;-3/5;-1/5;1/5;3/5;1];
  wf=[19;75;50;50;75;19]/144;
elseif ( m == 6 )
  bp=[-1;-2/3;-1/3;0;1/3;2/3;1];
  wf=[41;216;27;272;27;216;41]/420;
elseif ( m == 7 )
  bp=[-1;-5/7;-3/7;-1/7;1/7;3/7;5/7;1];
  wf=[751;3577;1323;2989;2989;1323;3577;751]/8640;
else
  if ( m != 8 )
    disp('Dont know formula higher than n=8.  Returning as if n=8.');
  endif
  bp=[-1;-3/4;-1/2;-1/4;0;1/4;1/2;3/4;1];
  wf=[989;5888;-928;10496;-4540;10496;-928;5888;989]/14175;
endif

endfunction
