function [numc,denc,msg] = tfchk(num,den)
%TFCHK  Check for proper transfer function.
%   [NUMc,DENc] = TFCHK(NUM,DEN) returns equivalent transfer function
%   numerator and denominator where LENGTH(NUMc) = LENGTH(DENc) if
%   the transfer function NUM,DEN are proper.  Prints an error message
%   if not.
%   A third output returns the error message instead if erroring
%   to the command line.

%   Clay M. Thompson 6-26-90
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $  $Date: 2004/04/16 22:08:15 $

no = nargout;
[nn,mn] = size(num);
[nd,md] = size(den);

% Make sure DEN is a row vector, NUM is assumed to be in rows.
if nd > 1,
    msg.message = 'Denominator must be a row vector.';
    msg.identifier = 'MATLAB:tfchk:denominatorNotRowVector';
elseif (mn > md),
    msg.message = 'Transfer function not proper.';
    msg.identifier = 'MATLAB:tfchk:improperTransferFunction';
else
    msg.message = '';
    msg.identifier = '';
    msg = msg(zeros(0,1));
end

if (no < 3)
    error(msg);
end

% Make NUM and DEN lengths equal.
numc = [zeros(nn,md-mn),num];
denc = den;

% end tfchk
