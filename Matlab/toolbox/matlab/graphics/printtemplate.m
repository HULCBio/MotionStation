function pt = printtemplate( varargin )
%PRINTTEMPLATE Constructor for PrintTemplate objects.
%   PrintTemplate is an object used to encapsulate settings and methods
%   to format Figures and models during output. This constructor defines
%   each class variable and supplies default values. Methods of this object
%   will be called during the export process to manipulate Handle Graphics
%   and Simulink model properties to achieve the desired output.
%
%   See also PRINT, @PRINTJOB.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 17:08:21 $

if nargin == 1 & (isa(varargin{1}, 'printtemplate') | isstruct(varargin{1}))
    %Copy creation
    pt = varargin{1};
    return
end

pt.VersionNumber = 1.0;

pt.Name = '';               %Name for this template
pt.FrameName = '';          %Name of printframe, if any, to use

%Lines and Text objects do not look good dithered, user can ask for them not to be.
pt.DriverColor = 0;         %True if want Lines and Text left in color

pt.AxesFreezeTicks = 0;     %True if Axes output with same tick marks as on screen
pt.tickState = {};          %Cell array of Axes handles and XYZtickMode values
pt.AxesFreezeLimits = 0;    %True if Axes output with same limits as on screen
pt.limState = {};           %Cell array of Axes handles and XYZlimMode values

pt.Loose = 0;               %Use loose bounding box for PS and Ghostscript drivers
pt.CMYK = 0;                %Use CMYK colors in PS and Ghostscript drivers instead of RGB
pt.Append = 0;              %Append to existing PS file without overwriting
pt.Adobecset = 0;           %Use Adobe PS default character set encoding
pt.PrintUI = 1;             %Print user interface controls
pt.Renderer = 'auto';       %Print using a specific renderer
pt.ResolutionMode = 'auto'; %Print using a specified resolution
pt.DPI = 0;                 %Resolution to use when ResolutionMode is 'manual'
pt.FileName = 'untitled';   %The name last used to save this object to disk
pt.Destination = 'printer'; %'file' | 'printer'; where last PRINT command exported object
                            %Gets name of last printer used from appdata, or preferences when available
pt.PrintDriver = '';        %Driver used when this Figure was last printed

pt.DebugMode = 0;           %Boolean true to output diagnostics while printing.

%CREATE_CLASS
%pt=class(pt,'printtemplate');    %Define the MATLAB oops class
%END_CLASS
