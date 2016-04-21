function I = eye(n,m,cls)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) The dimensions are required to be integer values, e.g. it
%    cannot handle eye(3.2) despite MATLAB returns a 3x3 matrix.
% 2) In MATLAB you can pass negative values to eye, e.g. eye(-1)
%    but it is equivalent to eye(0).
% 3) In MATLAB you can pass complex values to eye, e.g. eye(3+2i),
%    but it just ignores the imaginary value; this function
%    errors out.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/eye.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:11 $

if nargin == 0
    I = 1;
    return
end

switch nargin,
   case 1,
    if ischar(n),
        if ~strcmp(n,'single') && ~strcmp(n,'double'),
            eml_assert(0,'error',...
            'Only input must be numeric or a valid numeric class name.');
end;
        I = eye_internal(1,1,n);
    elseif isscalar(n),
	    I = eye_internal(n,n,'double');
	else
	    eml_assert( size(n,1) == 1 && size(n,2) == 2,...
			'error',...
			'Row vector must be of size 2' );
	    I = eye_internal(n(1),n(2),'double');
	end
   case 2,
	if ischar(m),
	    if isscalar(n),
   	        I = eye_internal(n,n,m);
	    else
   	        eml_assert( size(n,1) == 1 && size(n,2) == 2,...
		   	    'error',...
			    'Row vector must be of size 2' );
	        I = eye_internal(n(1),n(2),m);
	    end
else
	    I = eye_internal(n,m,'double');
    end
   case 3,
	I = eye_internal(n,m,cls);
   otherwise,
	eml_assert(0,'error','Internal error');
end

function I = eye_internal(n,m,cls)

eml_assert(isscalar(n), 'error', 'Dimensions must be scalars.' );
eml_assert(isscalar(m), 'error', 'Dimensions must be scalars.' );
   eml_assert(n >= 0, 'error', 'Negative dimensions not allowed.' );
   eml_assert(m >= 0, 'error', 'Negative dimensions not allowed.' );
eml_assert(isreal(n), 'error', 'Dimensions must be real values.');
eml_assert(isreal(m), 'error', 'Dimensions must be real values.');
eml_assert(ischar(cls) && ...
           (strcmp(cls,'single') || strcmp(cls,'double')),...
           'error', ...
           'Trailing string input must be a valid numeric class name.');

if n == m,
   I = diag(ones(n,1,cls)); % I am not sure if this is more efficient...
else
   I = zeros(n,m,cls);
   q = min(n,m);
   if q > 0,
       for i=1:q,
          I(i,i) = 1;
       end
   end
end
