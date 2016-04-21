function outGeom = sluigeom(units)
%SLUIGEOM Provides width & height adjustments for uicontrols.
%   SLUIGEOM with no arguments, sluigeom returns the amount of extra space 
%   taken up by each control on the current platform. For example, if a
%   string is 10 pixels wide, then to place that string into a checkbox, the
%   checkbox must be 10 + dx pixels wide.
%
%   Example:
%     geom = sluigeom;
%     stringWidth   = 10;
%     stringHeight  = 16;
%     controlWidth  = stringWidth  + geom.checkbox(3);
%     controlHeight = stringHeight + geom.checkbox(4);
%     pos = [8 8 controlWidth controlHeight];
%     uicontrol('string',str,'style','checkbox','pos',pos);
%
%   This function is useful for creating consistent UI's across all supported 
%   platforms.  For example, an edit control on the PC for a fontsize of 10 
%   needs to be w by h pixels.  On XWindows (with a fontsize of 10), the edit 
%   control will need to be w + dw by h + dh in order to account for the beveled
%   edges that XWindows places at the edges of edit controls.  This function 
%   returns dw and dh.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

if (nargin == 0),
  units = 'pixels';
end

switch(units),

  case 'points',
    %
    % convert pixels to points [ pix * (inch/pix) * (72 points/inch) ]
    %

    inchPerPix = 1/get(0, 'ScreenPixelsPerInch');
    scale = inchPerPix * 72;

    fudgeFactors = ceil(i_CreateGeomStruct * scale);
    
  case 'pixels',
    %
    % return pixels
    %
      
    fudgeFactors = i_CreateGeomStruct;

  case 'character',
    %
    % return character units
    %
    fudgeFactors = i_CreateGeomStructForCharUnits;

  otherwise,
    error('units must be ''pixels'' or ''character'' or ''points''');

end


outGeom.pushbutton      =  fudgeFactors(1,:);
outGeom.radiobutton     =  fudgeFactors(2,:);
outGeom.checkbox        =  fudgeFactors(3,:);
outGeom.edit            =  fudgeFactors(4,:);
outGeom.text            =  fudgeFactors(5,:);
outGeom.slider          =  fudgeFactors(6,:);
outGeom.frame           =  fudgeFactors(7,:);
outGeom.listbox         =  fudgeFactors(8,:);
outGeom.popupmenu       =  fudgeFactors(9,:);
outGeom.listboxHscroll  =  fudgeFactors(10,:);
outGeom.listboxVscroll  =  fudgeFactors(11,:);


% Function =====================================================================
% Function - create goemetry factors for given computer type.  Matrix rows are
% as shown in main function in assignment of outGeom.  Matrix colums are:
% [0 0 width height] measured as the number of extra pixels used by system 
% decoration

function geom = i_CreateGeomStruct;

if isunix
    geom = [
        0  0  4  4   %pushbutton
        0  0  26 4   %radiobutton
        0  0  26 4   %checkbox
        0  0  4  4   %edit
        0  0  0  0   %text
        0  0  0  0   %slider
        0  0  4  4   %frame
        0  0  4  4   %listbox
        0  0  26 6   %popupmenu
        0  0  0  17  %height of horizontal listbox scroll bar
        0  0  19 0   %width of vertical listbox scroll bar
    ];

elseif ispc

    geom = [
        0  0  4  4   %pushbutton
        0  0  18 0   %radiobutton
        0  0  18 0   %checkbox
        0  0  7  4   %edit
        0  0  0  0   %text
        0  0  0  0   %slider
        0  0  2  2   %frame
        0  0  16 2   %listbox
        0  0  20 4   %popupmenu
        0  0  0  18  %height of horizontal listbox scroll bar
        0  0  0  0   %width of vert listbox scroll bar (not needed)
    ];
else
    error(['Invalid computer type ', computer, ' in sluigeom.m' ]);  

end

% Function =====================================================================
% Function - create goemetry factors for given computer type.  Matrix rows are
% as shown in main function in assignment of outGeom.  Matrix colums are:
% [0 0 width height] measured as the number of extra character units used by
% system decoration
%
% NOTE: This table is currently incomplete.

function geom = i_CreateGeomStructForCharUnits;

if isunix
    geom = [
        0  0  2   0.7   %pushbutton
        0  0  0   0.55  %radiobutton
        0  0  3.6 1     %checkbox
        0  0  2   0.7   %edit
        0  0  0   0.33  %text
        0  0  0   0     %slider
        0  0  0   0     %frame
        0  0  0   0     %listbox
        0  0  5   0.9   %popupmenu
        0  0  0   0     %height of horizontal listbox scroll bar
        0  0  0   0     %width of vert listbox scroll bar (not needed)
  ];
elseif ispc

    geom = [
        0  0  3   0.6   %pushbutton
        0  0  0   0.35  %radiobutton
        0  0  3.6 0.1   %checkbox
        0  0  3   0.5   %edit
        0  0  0.5 0.3   %text
        0  0  0   0     %slider
        0  0  0   0     %frame
        0  0  0   2     %listbox
        0  0  5   0.55  %popupmenu
        0  0  0   0     %height of horizontal listbox scroll bar
        0  0  0   0     %width of vert listbox scroll bar (not needed)
    ];
else
    error(['Invalid computer type ', computer, ' in sluigeom.m' ]);  

end












