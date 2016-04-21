function s = num2str(x, f)
%NUM2STR Convert numbers to a string.
%   T = NUM2STR(X) converts the matrix X into a string representation T
%   with about 4 digits and an exponent if required.  This is useful for
%   labeling plots with the TITLE, XLABEL, YLABEL, and TEXT commands.
%
%   T = NUM2STR(X,N) converts the matrix X into a string representation
%   with a maximum N digits of precision.  The default number of digits is
%   based on the magnitude of the elements of X.
%
%   T = NUM2STR(X,FORMAT) uses the format string FORMAT (see SPRINTF for
%   details).
%
%   Example:
%       num2str(randn(2,2),3) produces the string matrix
%
%       '-0.433    0.125'
%       ' -1.67    0.288'
%
%   See also INT2STR, SPRINTF, FPRINTF, MAT2STR.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.32.4.8 $  $Date: 2004/04/16 22:08:44 $

%------------------------------------------------------------------------------
% if input does not exist or is empty, throw an exception
if nargin<1
    error('MATLAB:num2str:NumericArrayUnspecified',...
        'Numeric array is unspecified')
end
% If input is a string, return this string.
if ischar(x)
    s = x;
    return
end
if isempty(x)
    s = '';
    return
end

maxDigitsOfPrecision = 256;
floatFieldExtra = 7;
intFieldExtra = 2;
maxFieldWidth = 12;
floatWidthOffset = 4;
	
% Compose sprintf format string of numeric array.
if (nargin < 2 && ~isempty(x)) && all(all(x==fix(x)))
	if isreal(x)
	    % The precision is unspecified; the numeric array contains whole numbers.
		s = int2str(x);
		return;
	else
		%Complex case
		% maximum field width is 12 digits
		xmax = double(max(abs(x(:))));
		if xmax == 0
			d = 1;
		else
			d = min(maxFieldWidth, floor(log10(xmax)) + 1);	
		end

		% Create ANSI C print format string.
		f = ['%' sprintf('%d',d+intFieldExtra) 'd'];    % real numbers
		fi = ['%-' sprintf('%d',d+intFieldExtra) 's'];  % imaginary numbers
	end
elseif nargin < 2
    % The precision is unspecified; the numeric array contains floating point
    % numbers.
	xmax = double(max(abs(x(:))));
	if xmax == 0
		d = 1;
	else
		d = min(maxFieldWidth, max(1, floor(log10(xmax))+1))+floatWidthOffset;	
	end
   
    % Create ANSI C print format string.
    % real numbers
    f = ['%' sprintf('%.0f',d+floatFieldExtra) '.' sprintf('%.0f',d) 'g'];
    % imaginary numbers
    fi = ['%-' sprintf('%.0f',d+floatFieldExtra) 's'];

elseif ~ischar(f)
    % Precision is specified, not as ANSI C format string, but as a number.
    % Windows gets a segmentation fault at around 512 digits of precision,
    % as if it had an internal buffer that cannot handle more than 512 digits
    % to the RIGHT of the decimal point. Thus, allow half of the windows buffer
    % of digits of precision, as it should be enough for most computations.
    % Large numbers of digits to the LEFT of the decimal point seem to be allowed.
    if f > maxDigitsOfPrecision
        error('MATLAB:num2str:exceededMaxDigitsOfPrecision', ...
            'Exceeded maximum %d digits of precision.',maxDigitsOfPrecision);
    end

    % Create ANSI C print format string
    fi = ['%-' sprintf('%.0f',f+floatFieldExtra) 's'];
    f = ['%' sprintf('%.0f',f+floatFieldExtra) '.' int2str(f) 'g'];
else
    % Precistion is specified as an ANSI C print format string.
    % Validate format string
    k = strfind(f,'%');
    if isempty(k), error('MATLAB:num2str:fmtInvalid', ...
            '''%s'' is an invalid format.',f);
    end
    % If digits of precision to the right of the decimal point are specified,
    % make sure it will not cause a segmentation fault under Windows.
    dotPositions = strfind(f,'.');
    if ~isempty(dotPositions)
        decimalPosition = find(dotPositions > k(1)); % dot to the right of '%'
        if ~isempty(decimalPosition)
            digitsOfPrecision = sscanf(f(dotPositions(decimalPosition(1))+1:end),'%d');
            if digitsOfPrecision > maxDigitsOfPrecision
                error('MATLAB:num2str:exceededMaxDigitsOfPrecision', ...
                    'Exceeded maximum %d digits of precision.',maxDigitsOfPrecision);
            end
        end
    end
    d = sscanf(f(k(1)+1:end),'%f');
    fi = ['%-' int2str(d) 's'];
end
%-------------------------------------------------------------------------------
% Print numeric array as a string image of itself.
[m,n] = size(x);
scell = cell(1,m);
xIsReal = isreal(x);
for i = 1:m,
    t = [];
    if xIsReal && (min(x(i,:)) >= 0) && (max(x(i,:)) < 2^31-1)
        t = sprintf(f,x(i,:));
    else

        for j = 1:n,
            u0 = sprintf(f, real(x(i,j)));
            % we add a space infront of the negative sign
            % because Win32 version of sprintf does not.
            if (j>1) && u0(1)=='-'
                u = [' ' u0];
            else
                u = u0;
            end
            % If we are printing integers and have overflowed, then
            % add in an extra space.
            if (real(x(i,j)) > 2^31-1) && (~isempty(findstr(f,'d')))
                u = [' ' u];
            end
            if ~xIsReal
                if imag(x(i,j)) == 0,
                    u = [u '+' formatimag(f,fi,0)];
                elseif imag(x(i,j)) > 0
                    u = [u '+' formatimag(f,fi,imag(x(i,j)))];
                elseif imag(x(i,j)) < 0
                    u = [u '-' formatimag(f,fi,-imag(x(i,j)))];
                end
            end
            t = [t u];
        end
    end
    scell{i} = t;
end
if m > 1
    s = strvcat(scell{:});
else
    s = t;
end
% Remove leading blanks
% If it's a scalar remove the trailing blanks too.
if length(x)==1,
    s = strrep(s,' ','');
else
    s = lefttrim(s);
end

%------------------------------------------------------------------------------
function v = formatimag(f,fi,x)
% Format imaginary part
v = [sprintf(f,x) 'i'];
v = lefttrim(v);
v = sprintf(fi,v);

%------------------------------------------------------------------------------
function s = lefttrim(s)
% Remove leading blanks
if ~isempty(s)
    [r,c] = find(s ~= ' ',1);
    if ~isempty(c)
        s = s(:,c:end);
    end
end
%--------------------------------------------------------------------------
%----
