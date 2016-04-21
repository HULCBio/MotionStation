function dokeypress(HG)
%DOKEYPRESS  Handle key press functions for plot editor figures

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/15 04:07:31 $

key = double(get(HG,'CurrentCharacter'));

if isempty(key)
   return
end

switch key
case {8 127} % Backspace and Delete
   cutcopypaste(HG,'clear');   
case 24 % ctrl-X
   cutcopypaste(HG,'cut');
case 3  % ctrl-C
   cutcopypaste(HG,'copy');
case 22 % ctrl-V
   cutcopypaste(HG,'paste');
end
