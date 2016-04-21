function postdeserialize(scribeax)

% Copyright 2003 The MathWorks, Inc.

shapes = scribeax.Shapes;
for k=1:length(shapes)
    if ishandle(shapes(k))
        shk = shapes(k);
        if isequal(shapes(k).shapetype,'legend')
            leginfo = shapes(k).methods('postdeserialize');
            delete(double(leginfo.leg));
            if strcmpi(leginfo.loc,'none')
                legend(leginfo.ax,leginfo.strings,'Location',leginfo.position);
            else
                legend(leginfo.ax,leginfo.strings,'Location',leginfo.loc);
            end
        else
            shapes(k).methods('postdeserialize');
        end
    end
end
