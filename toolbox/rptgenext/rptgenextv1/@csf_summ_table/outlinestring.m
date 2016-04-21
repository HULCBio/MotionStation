function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:40 $
if ( rgsf ('is_parent_valid', c ) )
   strout=sprintf('Stateflow %s', outlinestring(c.rpt_summ_table,c));
else
   strout = xlate('? Stateflow Summary Table (Invalid Parent)');
end

