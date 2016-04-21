function resp = write_string(ss,index,data)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2003/11/30 23:13:02 $

error(nargchk(2,3,nargin));
if ~ishandle(ss),
    error('First Parameter must be a STRING Handle.');
end
if nargin==2,   
    data = index;
end

is_character = 1;
if isnumeric(data),
    is_character = 0;
elseif ischar(data),
    data = equivalent(ss,data);
elseif iscellstr(data),
    data = strvcat(data);
    data = equivalent(ss,data);
end

if is_character,  
    % else if input is numeric, allow anything to be written; put restrictions in the future;
    % else, make the necessary adjustments : string must end with a NULL

    len_data = length(data);
	len_ss   = prod(ss.size);
    
    if nargin==3, 
        % Index specified, do not put NULL terminator
    elseif nargin==2 & len_ss==1, 
        % Object points to single char, do not append NULL;
        % If input data is >1 in length, allow superclass WRITE to throw the truncation warning
        
    elseif nargin==2 & len_ss~=1, 
        % object points to char array, append NULL
        %data = [data 0];                    
        
        for k = 1:size(data,1)
            if length(data(k,:)) > 1 % not a single char
                data(k,end+1) = 0; % plus NULL terminator
            end
        end
        
        % find all NULLs
        nullfound = find(data==0);
        if (~isempty(nullfound) && (length(nullfound) ==1))
            data = data(1:nullfound(1));
        end
        % string is too long
        if len_data>len_ss & len_ss~=1, 
            warning('String had been shortened to fit the allocated space.');
            data = [data(1:len_ss)];
        end
        
    end
    
end   

if nargin == 2,
    write_numeric(ss,data);
else
    write_numeric(ss,index,data);
end
    
% [EOF] write_string.m
