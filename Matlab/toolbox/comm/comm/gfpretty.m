function gfpretty(a,b,n)
%GFPRETTY Display a polynomial in traditional format.
%   GFPRETTY(A) displays the GF polynomial A in a traditional format,
%   omitting terms whose coefficients are zero.  A is a row vector that
%   specifies the polynomial coefficients in order of ascending powers.
%
%   GFPRETTY(A, STR) displays GF polynomial with the polynomial variable
%   specified in the string variable STR.
%
%   GFPRETTY(A, STR, N) uses screen width N instead of the default 79.
%
%   For correct spacing in the display, use a fixed-width font.
%
%   See also GFTUPLE, GFPRIMDF.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.14 $ $Date: 2002/03/27 00:07:53 $

% default values.
if nargin < 2
    b = 'X';
elseif ( ~isstr(b) | isempty(b) )
    error('The second input variable must be a string.');
end;

if nargin < 3
    n = 79;
end;

if isempty(a)
    return
end;

if ( (size(a,1) ~= 1) | ndims(a)~=2 )
    error('The input polynomial must be a row vector.');
end

if ( any(floor(a) ~= a) | any(~isreal(a)) | any(a<0) )
    error('The polynomial coefficients must be nonnegative integers.');
end

% initial condition
did = [];
diu = [];
a = gftrunc(a);

% assign string based on the GF polynomial
if length(a) <= 1
    did = num2str(a);
else
    for i=1:length(a)
        if a(i) ~= 0
            % the first one is constant
            if i == 1
                bb = num2str(a(1));
            else
                if abs(a(i)) == 1
                    bb = b;
                else
                    bb = [num2str(abs(a(i))), ' ', b];
                end;
            end;
            % the first assignment without '+'
            if isempty(did)
                did = bb;
                spa = length(bb);
            else
                if a(i) > 0
                    did = [did, ' + ', bb];
                else
                    did = [did, ' - ', bb];
                end;
                spa = length(bb) + 3;
            end;
            % match the power term
            if i > 2
                pow = num2str(i-1);
            else
                pow = '';
            end
            % set the string to be a same length
            diu = [diu, char(ones(1,spa)*32), pow];
            did = [did, char(ones(1,length(pow))*32)];
        end;
    end;
end;

% printout
if length(did) < n
    % under limit
    spa = floor((n-length(did))/2);
    pow = char(ones(1,spa)*32);
    did = [pow, did];
    diu = [pow, diu];
else
    %over the limit
    while(length(did) >= n)
        temp = length(did);
        ind = findstr(did, ' + ');
        sub_ind = max(find(ind < 79));
        disp(' ')
        disp(diu(1:max(ind(sub_ind)-1)));
        disp(did(1:max(ind(sub_ind)-1)));
        % add space for indent
        diu = ['          ',diu(ind(sub_ind):length(diu))];
        did = ['          ',did(ind(sub_ind):length(did))];
        if ( temp == length(did) ) % prevent looping
            break;
        end
    end;
end;

disp(' ')
disp(diu);
disp(did);

% [EOF]
