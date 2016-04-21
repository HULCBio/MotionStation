function strout=outlinestring(c)
%OUTLINESTRING

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:56:13 $

strout=strrep(outlinestring(c.rpt_summ_table,c),...
   'Fixed-Point Block','Fixpt');


