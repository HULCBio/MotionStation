function pj = printjob()
%PRINTJOB Constructor for PrintJob objects.
%   PrintJob is the object used to encapsulate all the data needed to export
%   Figures and models from MATLAB and Simulink. Constructor defines every
%   class variable and gives them default values. Comments in this file 
%   describe what each variable is for. It is not meant that MATLAB users 
%   will create PrintJob objects themselves; unless they are trying to take 
%   full control of the outputting of a Figure or graph. PrintJob is used by
%   the various M-files that control printing and image output from MATLAB
%   and Simulink.
%
%   Ex:
%      pj = PRINTJOB; 
%
%   See also PRINT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 17:06:00 $

pj.Handles = [];            %Matrix of handles to Figures and/or models to print
pj.Driver = '';             %Current driver chosen from list in tables
pj.FileName = '';           %Real or temp name of output
pj.PageNumber = 0;          %What page output we are currently drawing
pj.Active = 0;              %Currently connected to a driver
pj.Return = 0;              %Return value from HARDCOPY, could be meta handle or uint8 image

pj.AllFigures = [];         %Array of handles to all Figures, for setting Watch pointers
pj.AllPointers = [];        %String or cell array of strings of current Pointers

pj.PrinterName = '';        %Name of networked device to send output file
pj.SimWindowName ='';       %Name of Simulink model being printed
pj.Renderer = '';           %Renderer mode to use while printing/exporting
pj.rendererOption = 0;      %True if user specified renderer on cmd line
pj.PrintOutput = 0;         %True if want to send driver output to a device
pj.Verbose = 0;             %True if want to show system print dialog
pj.Orientation = '';        %Oiginal orientation of Figure/model if have to switch
pj.hgdata = [];             %Structure of data for restoration of Figure and children
pj.PaperUnits = '';         %Original PaperUnits while we work in Points

pj.PrintUI = 1;             %True if want to print UIControls (Beans/ActiveX?)
pj.nouiOption = 0;          %True if user specified -noui on cmd line
pj.UIData = [];             %Holds handles and data for faux Uicontrols
pj.DPI = -1;                %Resolution for Tiff, Jpeg, and PS, including for Ghostscript; -1 means use internal default

pj.DriverExt = '';          %Filename extension associated with current driver
pj.DriverClass = '';        %What type of driver is it, PS, Windows, ...
pj.DriverExport = 0;        %True if driver is an image format normally saved to disk

pj.DriverColor = 0;         %True if driver supports color (i.e. will not NODITHER)
pj.DriverColorSet = 0;      %True if command line arguments included device (which set DriverColor)

pj.GhostDriver = '';        %Holds onto driver requested from GS while we use PS
pj.GhostName = '';          %Eventual name from GS if generating temp PS file
pj.GhostImage = 0;          %True if converting PS to an image format for export or preview
pj.GhostExtent = [];        %Width and height in points of image/BoundingBox/PaperPosition
pj.GhostTranslation = [];   %All objects on page must be moved for GS image formats (including preview)

pj.PostScriptAppend = 0;    %True if want to append PS file to existing one
pj.PostScriptLatin1 = 1;    %True if want Latin 1 font encoding and not Adobe's
pj.PostScriptCMYK = 0;      %True if want colors in PS file to be CMYK and not RGB
pj.PostScriptTightBBox = 1; %True if want to have a tight BoundingBox
pj.PostScriptPreview = 0;   %'Enum' value of preview type, one of:
pj.TiffPreview = 1;         %Currently only supported preview type

[ pj.PrintCmd, pj.DefaultDevice ] = printopt; %Defaults
pj.Error = 0;               %Error condition
pj.DebugMode = 0;           %Boolean true want to output diagnostics while printing.

pj.Validated = 0;           %flag to say if this print job has been validated

pj.XTerminalMode = LocalXTerminalMode; %Boolean true if on Unix/VMS and not X

%CREATE_CLASS
%pj=class(pj,'printjob');
%END_CLASS


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalXTerminalMode %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalXTerminalMode()
%XTerminalMode True or False that MATLAB is running in terminal mode, 
% no X DISPLAY  on Unix.
bool = 0;
if ~( strcmp( computer, 'PCWIN' ) )
    if ~strcmp( get(0,'TerminalProtocol'), 'x' )
        bool = 1;
    end
end
