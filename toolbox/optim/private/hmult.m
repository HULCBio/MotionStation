function W = hmult(Hinfo,Y,varargin);
%HMULT	Hessian-matrix product
%
% W = HMULT(Y,Hinfo) An example of a Hessian-matrix product function
% file, e.g. Hinfo is the actual Hessian and so W = Hinfo*Y.
%
% Note: varargin is not used but must be provided in case 
% the objective function has additional problem dependent
% parameters (which will be passed to this routine as well).

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/02/07 19:13:38 $

W = Hinfo*Y;





