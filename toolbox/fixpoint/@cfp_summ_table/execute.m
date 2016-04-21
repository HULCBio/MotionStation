function out=execute(c)
%EXECUTE generates the report tags

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:06 $

out=feval('execute',c.rpt_summ_table,c);