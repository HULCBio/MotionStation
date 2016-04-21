function resp = write_rstring(rs,index,data)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2003/11/30 23:12:23 $

error(nargchk(2,3,nargin));
if ~ishandle(rs),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RSTRING Handle.');
end
if nargin==2,   
    data = index;
end

if nargin==3 & prod(index)~=1
    error(generateccsmsgid('InvalidSizeAssignment'),'Register objects are always scalar');
end

is_character = 1;
if isnumeric(data),
    is_character = 0;
elseif ischar(data),
    data = equivalent(rs,data);
elseif iscellstr(data),
    data = equivalent(rs,data{1});
end

if is_character,  
    % else if input is numeric, allow anything to be written; put restrictions in the future;
    % else, make the necessary adjustments : string must end with a NULL

    len_data = length(data);
	len_ss   = prod(rs.size);
    
    if nargin==3, 
        % Index specified, do not put NULL terminator
    elseif nargin==2 & len_ss==1, 
        % Object points to single char, do not append NULL;
        % If input data is >1 in length, allow superclass WRITE to throw the truncation warning
    elseif nargin==2 & len_ss~=1, 
        % object points to char array, append NULL
  
        data = [data 0]; % plus NULL terminator
        % find all NULLs
        nullfound = find(data==0);
        if ~isempty(nullfound)
            data = data(1:nullfound(1));
        end
        % string is too long
        if len_data>len_ss & len_ss~=1, 
            warning(generateccsmsgid('DataIsTruncated'),'String had been shortened to fit the allocated space.');
            data = [data(1:len_ss)];
        end
        
	end
end   

if nargin == 2, 
    write_rnumeric(rs,data);
else            
    write_rnumeric(rs,index,data);
end
    
% [EOF] write_rstring.m
