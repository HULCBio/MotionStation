function parse_output = add(td,typename,typeeqv)
% ADD Adds a new type entry to the TYPE class.
%  O = ADD(TD,TYPENAME,TYPEEQV)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:13:55 $

error(nargchk(3,3,nargin));
if ~ischar(typename),
    error('Second Parameter must be the type name in string format. ');
end
if ~ischar(typeeqv),
    error('Third Parameter must be the equivalent base type in string format. ');
end

% 1. Check if native C data type
parse_output = p_IsNativeCType(td,typeeqv);
if isempty(parse_output),
    try
        % 2. Check if a custom data type
        parse_output = list(td,typeeqv);
    catch
        try 
            % 3. Lastly, use parser to check data type
            parse_output = parse(td,typeeqv);
        catch
            error(sprintf(['A problem occurred while parsing equivalent base type : \n',...
                    lasterr ]));
        end
    end
end

p_Append(td,typename,parse_output);

% [EOF] add.m