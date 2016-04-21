function boo = isreal(sys)
%ISREAL   Checks if the model SYS is real-valued.

%      Author: P. Gahinet
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.3 $  $Date: 2002/04/10 06:08:28 $

boo = all(cellfun('isreal',sys.num(:))) & ...
    all(cellfun('isreal',sys.den(:)));
