function s = int2str(x)
%INT2STR Convert integer to string.
%   S = INT2STR(X) rounds the elements of the matrix X to
%   integers and converts the result into a string matrix.
%   Return NaN and Inf elements as strings 'NaN' and 'Inf', respectively.
%
%   See also NUM2STR, SPRINTF, FPRINTF, MAT2STR.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.20.4.6 $  $Date: 2004/04/16 22:08:40 $

x = round(real(x));
if length(x) == 1
    % handle special case of single infinite or NaN element
    if isfinite(x)
        s = sprintf('%.1f',x); % .1 to avoid precision loss on hpux
        s = s(1:length(s)-2);  % remove .d decimal digit
    else
        s = sprintf('%.0f',x);
    end
else

    t = '';
    [m,n] = size(x);
    % Determine elements of x that are finite.
    xfinite = x(isfinite(x));
    % determine the variable text field width quantity
 
	xmax = double(max(abs(xfinite(:))));
	if xmax == 0
		d = 1;
	else
		d = floor(log10(xmax)) + 1;	
	end

    clear('xfinite')
    % delimit string array with one space between all-NaN or all-Inf columns
    if any(isnan(x(:)))||any(isinf(x(:)))
        d = max([d;3]);
    end
    % create cell arrays for storage
    scell = cell(1,m);
    empties = true(1,m);
    % Have to make a special case for HP as it has different behavior for
    % format '%*.0f'.
    if(strcmpi(computer,'HPUX'))
        HPUXFlag = true;
    else
        HPUXFlag = false;
    end
    % walk through numbers array and convert elements to strings
    for i = 1:m
        if HPUXFlag == false
            % use vectorized version of sprintf
            if n > 1
                t = sprintf('%*.0f',[repmat((d+2),1,n);x(i,:)]);
            else
                t = sprintf('%*.0f',d+2,x(i,:));
            end
        else  % special case for HPUX
            t = '';
            for j = 1:n
                if isfinite(x(i,j))
                    p = sprintf('%*.1f',d+4,x(i,j)); % .1 to avoid precision loss on hpux
                    p = p(1:length(p)-2); % remove .d decimal digit
                    t = [t p];
                else
                    t = [t sprintf('%*.0f',d+2,x(i,j))];
                end
            end
        end
        if ~isempty(t)
            scell{i} = t;
            empties(i) = false;
        end
    end
    if m > 1
        s = char(scell{~empties});
    else
        s = t;
    end
    % trim leading spaces from string array within constraints of rectangularity.
    if ~isempty(s)
        while all(s(:,1) == ' ')
            s(:,1) = [];
        end
    end
end
