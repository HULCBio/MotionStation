function c=setloopthing(c,thing)
%SETLOOPTHING Sets looping information

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:18 $

c=subsasgn(c,substruct('.','ref','.','loopthing'),thing);
