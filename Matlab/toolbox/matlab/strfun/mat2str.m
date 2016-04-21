function string = mat2str(matrix, varargin)
%MAT2STR Convert a 2-D matrix to a string in MATLAB syntax.
%   STR = MAT2STR(MAT) converts the 2-D matrix MAT to a MATLAB
%   string so that EVAL(STR) produces the original matrix (to
%   within 15 digits of precision).  Non-scalar matrices are
%   converted to a string containing brackets [].
%
%   STR = MAT2STR(MAT,N) uses N digits of precision.
%
%   STR = MAT2STR(MAT, 'class') creates a string with the name of the class
%   of MAT included.  This option ensures that the result of evaluating STR
%   will also contain the class information.
%
%   STR = MAT2STR(MAT, N, 'class') uses N digits of precision and includes
%   the class information.
%
%   Example
%       mat2str(magic(3)) produces the string '[8 1 6; 3 5 7; 4 9 2]'.
%       a = int8(magic(3))
%       mat2str(a,'class') produces the string
%                  'int8([8 1 6; 3 5 7; 4 9 2])'.
%
%   See also NUM2STR, INT2STR, SPRINTF, CLASS, EVAL.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.28.4.5 $  $Date: 2004/04/16 22:08:42 $

if nargin > 3
    error('MATLAB:mat2str:Nargin','Takes at most 3 input arguments.');
end
numoptions = length(varargin);
useclass = false;
usedigits = false;
for i = 1:numoptions
    if ischar(varargin{i}) && isequal(varargin{i}, 'class')
        useclass = true;
    elseif isnumeric(varargin{i})
        usedigits = true;
        n = varargin{i};
    end
end

if ischar(matrix),
    string = matrix;
    return
end

if (ndims(matrix) > 2)
    error('MATLAB:mat2str:TwoDInput','Input matrix must be 2-D.');
end

if useclass
    string = [class(matrix), '('];
else
    string = '';
end

[rows, cols] = size(matrix);
if isempty(matrix)
    if (rows==0) && (cols==0)
        string = [string '[]'];
    else
        string = [string 'zeros(' int2str(rows) ',' int2str(cols) ')'];
    end
    if useclass
        string = [string, ')'];
    end
    return
end
if usedigits == false
    n = 15;
    form = '%.15g';
else
    form = sprintf('%%.%dg',n);
end
pos = length(string)+1;
% now guess how big string will need to be
% n+7 covers (space) or +-i at the start of the string, the decimal point
% and E+-00. The +10 covers class string and parentheses.
if ~isreal(matrix)
    spaceRequired = (2*(n+7)) * numel(matrix) + 10;
    realFlag = false;
else
    spaceRequired = ((n+7) * numel(matrix)) + 10;
    realFlag = true;
end
string(1,spaceRequired) = char(0);

if rows*cols ~= 1
    string(pos) = '[';
    pos = pos + 1;
end

for i = 1:rows
    for j = 1:cols
        if(matrix(i,j) == Inf)
            string(pos:pos+2) = 'Inf';
            pos = pos + 3;
        elseif (matrix(i,j) == -Inf)
            string(pos:pos+3) = '-Inf';
            pos = pos + 4;
        elseif islogical(matrix(i,j))
            if matrix(i,j) % == true
                string(pos:pos+3) = 'true';
                pos = pos + 4;
            else
                string(pos:pos+4) = 'false';
                pos = pos + 5;
            end
        else
            if realFlag || isreal(matrix(i,j))
                tempStr = sprintf(form,matrix(i,j));
                len = length(tempStr);
                string(pos:pos+len-1) = tempStr;
                pos = pos+len;
            else
                tempStr = sprintf(form,real(matrix(i,j)));
                len = length(tempStr);
                string(pos:pos+len-1) = tempStr;
                pos = pos+len;
                if(imag(matrix(i,j)) < 0)
                    tempStr = ['-i*',sprintf(form,abs(imag(matrix(i,j))))];
                else
                    tempStr =  ['+i*',sprintf(form,imag(matrix(i,j)))];
                end
                len = length(tempStr);
                string(pos:pos+len-1) = tempStr;
                pos = pos+len;
            end
        end
        string(pos) = ' ';
        pos = pos + 1;
    end
    string(pos-1) = ';';
end
% clean up the end of the string
if rows * cols ~= 1
    string(pos-1) = ']';
else
    % remove trailing space from scalars
    pos = pos - 1;
end
if useclass
    string(pos) = ')';
    pos = pos+1;
end
string = string(1:pos-1);
% end mat2str
