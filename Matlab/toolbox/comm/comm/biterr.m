function [num, rat, loc] = biterr(varargin)
%BITERR Compute number of bit errors and bit error rate.
%   [NUMBER,RATIO] = BITERR(X,Y) compares the unsigned binary representation of
%   the elements in the two matrices X and Y.  The number of differences in the
%   binary representation is output in NUMBER.  The ratio of NUMBER to the
%   total number of bits used in the binary representation is output in RATIO.
%   The same number of bits is used to represent each element in both X and Y.
%   The number of bits used is the smallest number required to represent the
%   largest element in either X or Y.  When one of the inputs is a matrix and
%   the other is a vector the function performs either a column-wise or
%   row-wise comparison based on the orientation of the vector.
%
%   Column : When one of the inputs is a matrix and the other is a column
%   Wise     vector with as many elements as there are rows in the input
%            matrix, a column-wise comparison is performed.  In this mode the
%            binary representation of the input column vector is compared with
%            the binary representation of each column of the input matrix. By
%            default the results of each column comparison are output and both
%            NUMBER and RATIO are row vectors. To override this default and
%            output the overall results, use the 'overall' flag(see below).
%   Row    : When one of the inputs is a matrix and the other is a row vector
%   Wise     with as many elements as there are columns in the input matrix, a
%            row-wise comparison is performed.  In this mode the binary
%            representation of the input row vector is compared with the binary
%            representation of each row of the input matrix.  By default the
%            results of each row comparison are output and both NUMBER and
%            RATIO are column vectors.  To override this default and output the
%            overall NUMBER and RATIO, use the 'overall' flag(see below).
%
%   In addition to the two matrices, two optional parameters can be given:
%
%   [NUMBER,RATIO] = BITERR(...,K) The number of bits used to represent each
%   element is given by K.  K must be a positive scalar integer no smaller than
%   the minimum number of bits required to represent the largest element in
%   both input matrices.
%
%   [NUMBER,RATIO] = BITERR(...,FLAG) uses FLAG to specify how to perform and
%   report the comparison.  FLAG has three possible values: 'column-wise',
%   'row-wise' and 'overall'.  If FLAG is 'column-wise' then BITERR compares
%   each individual column and outputs the results as row vectors. If FLAG is
%   'row-wise' then BITERR compares each individual row and outputs the results
%   as column vectors.  Lastly, if FLAG is 'overall' then BITERR compares all
%   elements together and outputs the results as scalars.
%
%   [NUMBER,RATIO,INDIVIDUAL] = BITERR(...) outputs a matrix representing the
%   results of each individual binary comparison in INDIVIDUAL.  If two
%   elements are identical then the corresponding element in INDIVIDUAL is
%   zero.  If the two elements are different then the corresponding element
%   in INDIVIDUAL is the number of binary differences.  INDIVIDUAL is
%   always a matrix, regardless of mode.
%
%   Examples:
%   >> A = [1 2 3; 1 2 2];
%   >> B = [1 2 0; 3 2 2];
%
%   >> [Num,Rat] = biterr(A,B)        >> [Num,Rat] = biterr(A,B,3)
%   Num =                            Num =
%        3                                3
%   Rat =                            Rat =
%       0.2500                           0.1667
%
%   >> [Num,Rat,Ind] = biterr(A,B,3,'column-wise')
%   Num =
%        1      0      2
%   Rat =
%       0.1667  0     0.3333
%   Ind =
%        0      0      2
%        1      0      0
%
%   See also SYMERR.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/12 23:00:31 $

% --- Typical error checking.
error(nargchk(2,4,nargin));

% --- Placeholder for the signature string.
sigStr = '';
flag = '';
K = [];

% --- Identify string and numeric arguments
for n=1:nargin
    if(n>1)
        sigStr(size(sigStr,2)+1) = '/';
    end
    % --- Assign the string and numeric flags
    if(ischar(varargin{n}))
        sigStr(size(sigStr,2)+1) = 's';
    elseif(isnumeric(varargin{n}))
        sigStr(size(sigStr,2)+1) = 'n';
    else
        error('Only string and numeric arguments are accepted.');
    end
end

% --- Identify parameter signitures and assign values to variables
switch sigStr
    % --- biterr(a, b)
    case 'n/n'
        a		= varargin{1};
        b		= varargin{2};

        % --- biterr(a, b, K)
    case 'n/n/n'
        a		= varargin{1};
        b		= varargin{2};
        K		= varargin{3};


        % --- biterr(a, b, flag)
    case 'n/n/s'
        a		= varargin{1};
        b		= varargin{2};
        flag	= varargin{3};

        % --- biterr(a, b, K, flag)
    case 'n/n/n/s'
        a		= varargin{1};
        b		= varargin{2};
        K		= varargin{3};
        flag	= varargin{4};

        % --- biterr(a, b, flag, K)
    case 'n/n/s/n'
        a		= varargin{1};
        b		= varargin{2};
        flag	= varargin{3};
        K		= varargin{4};

        % --- If the parameter list does not match one of these signatures.
    otherwise
        error('Syntax error.');
end

if (isempty(a)) || (isempty(b))
    error('Required parameter empty.');
end

if ~(min(min(isfinite(a))) && min(min(isfinite(b)))) || ~(isreal(a) & isreal(b)) || max(max(a<0)) || max(max(b<0)) || max(max(floor(a)~=a)) || max(max(floor(b)~=b))
    error('Inputs must be finite, real, positive integers.');
end

% Determine the sizes of the input matrices.
[am, an] = size(a);
[bm, bn] = size(b);

% If one of the inputs is a vector, it can be either the first or second input.
% This conditional swap ensures that the first input is the matrix and the second is the vector.
if ((am == 1) && (bm > 1)) || ((an == 1) && (bn > 1))
    [a, b] = deal(b, a);
    [am, an] = size(a);
    [bm, bn] = size(b);
end

% Check the sizes of the inputs to determine the default mode of operation.
if ((bm == 1) && (am > 1))
    default_mode = 'row-wise';
    if (an ~= bn)
        error('Input row vector must contain as many elements as there are columns in the input matrix.');
    end
elseif ((bn == 1) && (an > 1))
    default_mode = 'column-wise';
    if (am ~= bm)
        error('Input column vector must contain as many elements as there are rows in the input matrix.');
    end
else
    default_mode = 'overall';
    if (am ~= bm) || (an ~= bn)
        error('Input matrices must be the same size.');
    end
end

% Check that the user specified mode of operation is valid.
if isempty(flag)
    flag = default_mode;
elseif ~(strcmp(flag,'column-wise') || strcmp(flag,'row-wise') || strcmp(flag,'overall'))
    error('Invalid string flag.');
elseif strcmp(default_mode,'row-wise') && strcmp(flag,'column-wise')
    error('A column-wise comparison is not possible with a row vector input.');
elseif strcmp(default_mode,'column-wise') && strcmp(flag,'row-wise')
    error('A row-wise comparison is not possible with a column vector input.');
end

% Determine the minimum number of bits needed to represent the matrices.
tmp = max( max(max(a)), max(max(b)) );
if (tmp > 0)
    sym_len = floor( log(tmp) / log(2) ) + 1;
else
    sym_len = 1;
end

% Check that the user specified 'symbol length' is valid.
if ~isempty(K)
    if max(size(K)) > 1
        error('Word length must be a scalar.');
    elseif (~isfinite(K)) || (floor(K)~=K) || (~isreal(K))
        error('Word length must be a finite, real integer.');
    elseif K < sym_len
        error('The specified word length is too short for the matrix elements.');
    else
        sym_len = K;
    end
end

a2 = toBinary(a, sym_len);
b2 = toBinary(b, sym_len);

% Two seperate flags are needed for the function to operate efficiently.
% 'default_mode' specifices if one of the inputs is actually a vector while
% the other is a matrix, meaning that the vector should be compared with each
% individual row or column of the matrix.  'flag' (which the user specifies)
% specifies how the results of this comparison are reported.

if strcmp(default_mode,'overall')
    if strcmp(flag,'column-wise')
        for i = 1:an
            num(1,i) = sum(sum(a2(:,((i-1)*sym_len+1):(i*sym_len)) ~= b2(:,((i-1)*sym_len+1):(i*sym_len))));
        end
        rat = num / (am*sym_len);
    elseif strcmp(flag,'row-wise')
        num = sum(a2~=b2,2);
        rat = num / (an*sym_len);
    else
        num = sum(sum(a2~=b2));
        rat = num / (am*an*sym_len);
    end
    if (nargout > 2)
        loc = zeros(am,an);
        for i = 1:an
            loc(:,i) = sum( (a2(:,((i-1)*sym_len+1):(i*sym_len)) ~= b2(:,((i-1)*sym_len+1):(i*sym_len))), 2);
        end
    end
elseif strcmp(default_mode,'column-wise')
    if (nargout < 3)
        for i = 1:an,
            num(1,i) = sum(sum(a2(:,((i-1)*sym_len+1):(i*sym_len))~=b2));
        end
    else
        loc = zeros(am,an);
        for i = 1:an,
            loc(:,i) = sum((a2(:,((i-1)*sym_len+1):(i*sym_len)) ~= b2), 2);
            num(1,i) = sum(loc(:,i));
        end
    end
    if strcmp(flag,'overall')
        num = sum(num);
        rat = num / (am*an*sym_len);
    else
        rat = num / (am*sym_len);
    end
else
    if (nargout < 3)
        for i = 1:am,
            num(i,1) = sum(a2(i,:)~=b2);
        end
    else
        loc = zeros(am,an);
        for i = 1:an
            for j = 1:am
                loc(j,i) = sum( (a2(j,((i-1)*sym_len+1):(i*sym_len)) ~= b2(1,((i-1)*sym_len+1):(i*sym_len))), 2);
            end
        end
        num(:,1) = sum(loc,2);
    end
    if strcmp(flag,'overall')
        num = sum(num);
        rat = num / (am*an*sym_len);
    else
        rat = num / (an*sym_len);
    end
end

%%%
function b = toBinary(a, sym_len)
% Convert matrix to binary representation

[am an] = size(a);
b = de2bi(a(:), sym_len);

% block transpose
b = reshape(permute(reshape(b', sym_len, am, an), [2 1 3]), am, sym_len*an);

% [EOF] biterr.m