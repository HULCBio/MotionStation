function p = procedurecolumns(d,c,s)
%PROCEDURECOLUMNS Get catalog's stored procedure parameters and result columns.
%   P = PROCEDURECOLUMNS(D,C,S) returns stored procedure parameter information for the 
%   given database metadata D, catalog C, and schema S.
%
%   P = PROCEDURECOLUMNS(D,C) returns stored procedure parameter information for
%   all schemas of the given catalog.
%
%   See also GET, PROCEDURES.

%   Author(s): C.F.Garvin, 08-17-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $   $Date: 2002/06/17 12:01:33 $

%Create com.mathworks.toolbox.database.databaseDMD instance
a = com.mathworks.toolbox.database.databaseDMD;

%Initialize schema, S, if not input
if nargin < 3
  s = {};
end

%%Get and parse procedure parameter information
tmp = dmdProcedureColumns(a,d.DMDHandle,c,s);
eval(['p = {' tmp '};'])
