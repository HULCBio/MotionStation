function cleartip(this)
%CLEARTIP  Clears data tip for all view objects.
 
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:59 $
for dv=this(:)'
   dv.addtip('');
end