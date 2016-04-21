function out=execute(c)
%EXECUTE generates the report tags

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:39 $

out=feval('execute',c.rpt_summ_table,c);