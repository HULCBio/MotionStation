function k = pickic(n)
%PICKIC Pick initial conditions.
%  
%  This function is obselete.

nntobsf('barerr','Use BAR to make bar plots.')

%  *WARNING*: PICKIC is undocumented as it may be altered
%  at any time in the future without warning.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.13 $  $Date: 2002/04/14 21:14:41 $

if nargin == 0, n = 0; end

k = 0;

if n == 0
  while (k ~= 1 & k ~= 2)
    disp('Would you like to use the weights & biases from:')
    disp(' ')
    disp('  (1) the code above?')
    disp('  (2) the User''s Guide?')
    k = input('What do you choose? ');
  end

elseif n == 1
  while (k ~= 1 & k ~= 2 & k ~= 3)
    disp('Would you like to use the weights & biases:')
    disp(' ')
    disp('  (1) from the code above?')
    disp('  (2) from the User''s Guide?')
    disp('  (3) from the Error Contour using the mouse?')
    k = input('What do you choose? ');
  end
end

