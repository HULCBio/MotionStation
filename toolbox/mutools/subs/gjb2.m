% function [svalue,color,linetype] = gjb2(value,mask)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [svalue,color,linetype] = gjb2(value,mask)


colortab  = abs('ymcrgbwk');
linsymtab = abs('-:.o+*x');

if isinf(value)
    svalue = '';
elseif isnan(value)
    svalue = '';
elseif isstr(value)
    value = deblank(value);
    value = abs(value);
    color = value(1);
%    delin = value(2);
    linetype1 = value(2);
    longflag = 0;
    if length(value) > 2
        linetype2 = value(3);
        longflag = 1;
    end

    if any(colortab == color) & any(linsymtab == linetype1)
        if longflag == 0
            color = setstr(value(1));
            svalue = 1000000*color  + 1000*linetype1;
            linetype = setstr(linetype1);
        elseif linetype1==abs('-') & any(linetype2==abs('-.'))
            svalue = 1000000*color  + 1000*linetype1 + linetype2;
            color = setstr(value(1));
            linetype = setstr([linetype1 linetype2]);
        else
            svalue = [];
        end
    else
        svalue = [];
    end
else %floating point number
    if mask == 0
        if (floor(value) == ceil(value)) & abs(value)<10000
            svalue = int2str(value);
        elseif value>=1e4 | value<=1e-4
            svalue = sprintf('%1.0e',value);
        elseif value<1 & value>0
            svalue = sprintf('%1.3f',value);
        else
            svalue = num2str(value);
        end
    elseif mask == 1
        svalue = setstr(value);
    elseif mask == 2
        color = round(value/1000000);
        lintype1 = round((value-1000000*color)/1000);
        lintype2 = round(value-1000000*color-1000*lintype1);
        svalue = setstr([color lintype1 lintype2]);
        color = setstr(color);
        linetype = setstr([lintype1 lintype2]);
    end
end