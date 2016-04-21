function displayParameters(xpcObj)
%DISPLAYPARAMETERS Displays model parameters (private)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:03:37 $

modelname = get(xpcObj,'Application');

eval(['pt =', modelname, 'pt;'], ...
     'error(''Parameter Information file does not exist'')');
npar  = length(pt);
index = 0;
for i = 1 : npar
   par       = pt(i);
   blockname = par.blockname;
%   sindex    = find(blockname == '/');
%   blockname = blockname(sindex(1) + 1 : end);
   if ((par.nrows == 1) & (par.ncols == 1))
     fprintf(2, '   %-23s%-8s%-18f%-10s%-8s%-30s%-30s\n', ' ', ...
	     ['P', num2str(index)], xpcgate('getpar', index), ...
	     par.subsource(4:end), 'Scalar', par.paramname, blockname);
     index   = index + 1;
   else
     fprintf(2, '   %-23s%-8s%-18s%-10s%-8s%-30s%-30s\n', ' ', ...
	     ['P', num2str(index)], '[...]', par.subsource(4:end), ...
	     [num2str(par.nrows), '*', num2str(par.ncols)], ...
	     par.paramname, blockname); 
      index  = index + 1;
   end
end
fprintf(2, '\n');

%% EOF displayParameters.m