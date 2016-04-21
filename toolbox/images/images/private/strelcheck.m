function se = strelcheck(in,func_name,arg_name,arg_position)
%STRELCHECK Check validity of STREL object, or convert neighborhood to STREL.
%   SE = STREL(IN) returns IN if it is already a STREL; otherwise it
%   assumes IN is a neighborhood-style array and tries to convert it to a
%   STREL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/08/23 05:54:23 $
  
if isa(in, 'strel')
    se = in;
else
    if ~( isnumeric(in) || islogical(in) )
        msgId = sprintf('Images:%s:invalidStrelType', func_name);
        msg1 = sprintf('Function %s expected its %s input argument, ',func_name, ...
                       num2ordinal(arg_position));
        msg2 = sprintf('%s, to be either numeric or logical.', arg_name);
        error(msgId,'%s %s',msg1,msg2);
              
    else
        if issparse(in)
            in = full(in);
        end
        in = double(in);
        if ~isempty(in)
            bad_elements = (in ~= 0) & (in ~= 1);
            if any(bad_elements(:))
                msgId = sprintf('Images:%s:invalidStrelValues', func_name);
                msg1 = sprintf('%s, the %s input argument to function %s,', ...
                               arg_name, num2ordinal(arg_position), func_name); 
                msg2 = ' contained values other than 0 or 1.';
                error(msgId,'%s %s',msg1,msg2);
            end
        end
        se = strel(in);
    end
end
