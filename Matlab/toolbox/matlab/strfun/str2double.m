function x = str2double(s)
%STR2DOUBLE Convert string to double precision value.
%   X = STR2DOUBLE(S) converts the string S, which should be an
%   ASCII character representation of a real or complex scalar value,
%   to MATLAB's double representation.  The string may contain digits,
%   a comma (thousands separator), a decimal point, a leading + or - sign,
%   an 'e' preceding a power of 10 scale factor, and an 'i' for
%   a complex unit.
%
%   If the string S does not represent a valid scalar value, STR2DOUBLE(S)
%   returns NaN.
%
%   X = STR2DOUBLE(C) converts the strings in the cell array of strings C
%   to double.  The matrix X returned will be the same size as C.  NaN will
%   be returned for any cell which is not a string representing a valid
%   scalar value. NaN will be returned for individual cells in C which are
%   cell arrays.
%
%   Examples
%      str2double('123.45e7')
%      str2double('123 + 45i')
%      str2double('3.14159')
%      str2double('2.7i - 3.14')
%      str2double({'2.71' '3.1415'})
%      str2double('1,200.34')
%
%   See also STR2NUM, NUM2STR, HEX2NUM, CHAR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2004/04/10 23:32:50 $

if ~isempty(s) && ischar(s)
    
    s = deblank(s);
    % Remove any commas so that numbers formatted like 1,200.34 are
    % handled.
    s(s==',') = [];

    lenS = length(s);
    % Try to get 123, 123i, 123i + 45, or 123i - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[ij] %1[+-] %f',4);
    % simlest case is a double
    if count == 1 && isempty(errmsg) && nextindex > lenS
        x = a;
        return;
    end
    % now deal with complex
    if isempty(errmsg) && nextindex > lenS
       if count==2
            x = a(1)*i;
        elseif count==4
            sign = (a(3)=='+')*2 - 1;
            x = a(1)*i + sign*a(4);
        else
            x = NaN;
        end
        return
    end

    % Try to get 123 + 23i or 123 - 23i
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[+-] %f %1[ij]',4);
    if isempty(errmsg) && nextindex > lenS
        if count==4
            sign = (a(2)=='+')*2 - 1;
            x = a(1) + sign*a(3)*i;
        else
            x = NaN;
        end
        return
    end

    % Try to get i, i + 45, or i - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%1[ij] %1[+-] %f',3);
    if isempty(errmsg) && nextindex > lenS
        if count==1
            x = i;
        elseif count==3
            sign = (a(2)=='+')*2 - 1;
            x = i + sign*a(3);
        else
            x = NaN;
        end
        return
    end

    % Try to get 123 + i or 123 - i
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[+-] %1[ij]',3);
    if isempty(errmsg) && nextindex > lenS
        if count==1
            x = a(1);
        elseif count==3
            sign = (a(2)=='+')*2 - 1;
            x = a(1) + sign*i;
        else
            x = NaN;
        end
        return
    end

    % Try to get -i, -i + 45, or -i - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%1[+-] %1[ij] %1[+-] %f',4);
    if isempty(errmsg) && nextindex > lenS
        if count==2
            sign = (a(1)=='+')*2 - 1;
            x = sign*i;
        elseif count==4
            sign1 = (a(1)=='+')*2 - 1;
            sign2 = (a(3)=='+')*2 - 1;
            x = sign1*i + sign2*a(4);
        else
            x = NaN;
        end
        return
    end

    % Try to get 123 + 23*i or 123 - 23*i
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[+-] %f %1[*] %1[ij]',5);
    if isempty(errmsg) && nextindex > lenS
        if count==5
            sign = (a(2)=='+')*2 - 1;
            x = a(1) + sign*a(3)*i;
        else
            x = NaN;
        end
        return
    end

    % Try to get 123*i, 123*i + 45, or 123*i - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[*] %1[ij] %1[+-] %f',5);
    if isempty(errmsg) && nextindex > lenS
        if count==1
            x = a;
        elseif count==3
            x = a(1)*i;
        elseif count==5
            sign = (a(4)=='+')*2 - 1;
            x = a(1)*i + sign*a(5);
        else
            x = NaN;
        end
        return
    end

    % Try to get i*123 + 45 or i*123 - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%1[ij] %1[*] %f %1[+-] %f',5);
    if isempty(errmsg) && nextindex > lenS
        if count==1
            x = i;
        elseif count==3
            x = i*a(3);
        elseif count==5
            sign = (a(4)=='+')*2 - 1;
            x = i*a(3) + sign*a(5);
        else
            x = NaN;
        end
        return
    end

    % Try to get -i*123 + 45 or -i*123 - 45
    [a,count,errmsg,nextindex] = sscanf(s,'%1[+-] %1[ij] %1[*] %f %1[+-] %f',6);
    if isempty(errmsg) && nextindex > lenS
        if count==2
            sign = (a(1)=='+')*2 - 1;
            x = sign*i;
        elseif count==4
            sign = (a(1)=='+')*2 - 1;
            x = sign*i*a(4);
        elseif count==6
            sign1 = (a(1)=='+')*2 - 1;
            sign2 = (a(5)=='+')*2 - 1;
            x = sign1*i*a(4) + sign2*a(6);
        else
            x = NaN;
        end
        return
    end

    % Try to get 123 + i*45 or 123 - i*45
    [a,count,errmsg,nextindex] = sscanf(s,'%f %1[+-] %1[ij] %1[*] %f',5);
    if isempty(errmsg) && nextindex > lenS
        if count==5
            sign = (a(2)=='+')*2 - 1;
            x = a(1) + sign*i*a(5);
        else
            x = NaN;
        end
        return
    end

    % None of the above cases, but s still is a character array.
    x = NaN;

elseif ~isempty(s) && iscellstr(s)
    for k=numel(s):-1:1,
        x(k) = str2double(s{k});
    end
    x = reshape(x,size(s));
elseif iscell(s)
	x = [];
	for k=numel(s):-1:1,
		if iscell(s{k})
			x(k) = NaN;
		else
			x(k) = str2double(s{k});
		end
    end
    x = reshape(x,size(s));
else
    x = NaN;
end
