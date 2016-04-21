function y = iterapp(afun,atype,afcnstr,x,varargin)
%ITERAPP   Apply matrix operator to vector and error gracefully.
%   ITERAPP(AFUN,ATYPE,AFCNSTR,X) applies matrix operator AFUN to vector X.
%   ATYPE and AFCNSTR are used in case of error.
%   ITERAPP(AFUN,ATYPE,AFCNSTR,X,...) allows extra arguments to AFUN(X,...).
%   ITERAPP is designed for use by iterative methods like PCG which
%   require matrix operators AFUN representing matrices A to operate on
%   vectors X and return A*X and may also have operators MFUN representing
%   preconditioning matrices M operate on vectors X and return M\X.
%
%   See also BICG, BICGSTAB, CGS, GMRES, PCG, QMR.

%   Penny Anderson, 1998.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $ $Date: 2003/05/19 11:16:34 $

try
   y = feval(afun,x,varargin{:});      
catch
   es = sprintf(['user supplied %s ==> %s\n' ...
         'failed with the following error:\n\n%s'],atype,afcnstr,lasterr);
   error('MATLAB:InvalidInput', es);
end

if (size(y,2) ~= 1)
   es = sprintf(['user supplied %s ==> %s\n' ...
         'must return a column vector.'],atype,afcnstr);
   error('MATLAB:MustReturnColumn', es)
end
