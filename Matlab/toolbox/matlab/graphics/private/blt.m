function bool = blt( pj, h )
%BLT Returns FALSE if Lines and Text objects in Figure should be printed in black.
%   Looks at settings of DriverColor and DriverColorSet of PrintJob object
%   and the PrintTemplate object, if any, in the Figure.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:29:02 $

%DriverColorSet was turned to TRUE iff there was a device cmd line argument
%If there was a cmd line device argument we use the DriverColor resulting from it
%otherwise we look for a PrintTemplate object in the Figure
%If there is one we return its DriverColor boolean value.

if pj.DriverColorSet
    bool = pj.DriverColor;
else
    pt = getprinttemplate(h);
    if isempty( pt )
        if strcmp( computer, 'PCWIN' ) & strncmp( pj.Driver, 'win', 3 )
            %PC driver properties' dialog allows users to set a color option.
            %PC code will call NODITHER if required.
            bool = 1; 
        else
            %Use setting based on default driver from PRINTOPT.
            bool = pj.DriverColor;
        end
    else
        bool = pt.DriverColor;
    end
end

bool = logical(bool);
