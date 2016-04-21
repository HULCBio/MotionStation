function varargout=setptr(fig,curs,fname)
%SETPTR Set figure pointer.
%   SETPTR(FIG,CURSOR_NAME) sets the cursor of the figure w/ handle FIG 
%   according to the cursor_name:
%      'hand'    - open hand for panning indication
%      'hand1'   - open hand with a 1 on the back
%      'hand2'   - open hand with a 2 on the back
%      'closedhand' - closed hand for panning while mouse is down
%      'glass'   - magnifying glass
%      'glassplus' - magnifying glass with '+' in middle
%      'glassminus' - magnifying glass with '-' in middle
%      'lrdrag'  - left/right drag cursor
%      'ldrag'   - left drag cursor
%      'rdrag'   - right drag cursor
%      'uddrag'  - up/down drag cursor
%      'udrag'   - up drag cursor
%      'ddrag'   - down drag cursor
%      'add'     - arrow with + sign
%      'addzero' - arrow with 'o'
%      'addpole' - arrow with 'x'
%      'eraser'  - eraser
%      'help'    - arrow with question mark ?
%      'modifiedfleur' - modified fleur
%      'rotate' - modified fleur
%      [ crosshair | fullcrosshair | {arrow} | ibeam | watch | topl | topr ...
%      | botl | botr | left | top | right | bottom | circle | cross | fleur ]
%           - standard figure cursors
%
%   SetData=setptr(CURSOR_NAME) returns a cell array containing 
%   the Property Value pairs which correctly set the pointer to 
%   the CURSOR_NAME specified. For example:
%       SetData=setptr('arrow');set(FIG,SetData{:})
 
%   Author: T. Krauss, 10/95
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.5 $  $Date: 2004/04/10 23:34:26 $ 

% now for custom cursors:
stringflag=0;
if isstr(fig),
  if nargin==2,fname=curs;end
  curs=fig;fig=[];
  stringflag=1;
end

mac_curs = 1;
switch curs
   case 'hand'
     d = ['01801A702648264A124D12496809980188024002200220041004080804080408'...
          '01801BF03FF83FFA1FFF1FFF6FFFFFFFFFFE7FFE3FFE3FFC1FFC0FF807F807F8'...
          '00090008']';
   case 'closedhand'
     d = ['00000000000000000DB0124C100A080218022002200220041004080804080408'...
          '00000000000000000DB01FFC1FFE0FFE1FFE3FFE3FFE3FFC1FFC0FF807F807F8'...
          '00090008']';
   case 'hand1'
     d = ['01801A702648264A124D1249680998818982408220822084108409C804080408'...
          '01801BF03FF83FFA1FFF1FFF6FFFFFFFFFFE7FFE3FFE3FFC1FFC0FF807F807F8'...
          '00090008']';
   case 'hand2'
     d = ['01801A702648264A124D1249680998C18922402220422084110409E804080408'...
          '01801BF03FF83FFA1FFF1FFF6FFFFFFFFFFE7FFE3FFE3FFC1FFC0FF807F807F8'...
          '00090008']';
   case 'glass'
     d = ['0F0030C04020402080108010801080104020402030F00F38001C000E00070002'...
          '0F0035C06AA05560AAB0D550AAB0D5506AA055703AF80F7C003E001F000F0007'...
          '00060006']';
   case 'glassplus'
        o=NaN; w=2; k=1;
        cdata = [...
            o o o o k k k k o o o o o o o o
            o o k k o w o w k k o o o o o o
            o k w o w k k o w o k o o o o o
            o k o w o k k w o w k o o o o o
            k o w o w k k o w o w k o o o o
            k w k k k k k k k k o k o o o o
            k o k k k k k k k k w k o o o o
            k w o w o k k w o w o k o o o o
            o k w o w k k o w o k o o o o o
            o k o w o k k w o w k w o o o o
            o o k k w o w o k k k k w o o o
            o o o o k k k k o w k k k w o o
            o o o o o o o o o o w k k k w o
            o o o o o o o o o o o w k k k w
            o o o o o o o o o o o o w k k k
            o o o o o o o o o o o o o w k w
            ];
       hotspot = [6 6];
       mac_curs = 0;
    case 'glassminus'
        o=NaN; w=2; k=1;
        cdata = [...
            o o o o k k k k o o o o o o o o
            o o k k o w o w k k o o o o o o
            o k w o w o w o w o k o o o o o
            o k o w o w o w o w k o o o o o
            k o w o w o w o w o w k o o o o
            k w k k k k k k k k o k o o o o
            k o k k k k k k k k w k o o o o
            k w o w o w o w o w o k o o o o
            o k w o w o w o w o k o o o o o
            o k o w o w o w o w k w o o o o
            o o k k w o w o k k k k w o o o
            o o o o k k k k o w k k k w o o
            o o o o o o o o o o w k k k w o
            o o o o o o o o o o o w k k k w
            o o o o o o o o o o o o w k k k
            o o o o o o o o o o o o o w k w
            ];
       hotspot = [6 6];
       mac_curs = 0;
   case 'lrdrag'
     d = ['00000280028002800AA01AB03EF87EFC3EF81AB00AA002800280028000000000'...
          '07C007C007C00FE01FF03FF87FFCFFFE7FFC3FF81FF00FE007C007C007C00000'...
          '00070007']';
   case 'ldrag'
     d = ['00000200020002000A001A003E007E003E001A000A0002000200020000000000'...
          '0700070007000F001F003F007F00FF007F003F001F000F000700070007000000'...
          '00070007']';
   case 'rdrag'
     d = ['000000800080008000A000B000F800FC00F800B000A000800080008000000000'...
          '00C000C000C000E000F000F800FC00FE00FC00F800F000E000C000C000C00000'...
          '00070007']';
   case 'uddrag'
     d = ['000000000100038007C00FE003807FFC00007FFC03800FE007C0038001000000'...
          '00000100038007C00FE01FF0FFFEFFFEFFFEFFFEFFFE1FF00FE007C003800100'...
          '00080007']';
   case 'udrag'
     d = ['000000000100038007C00FE003807FFC00000000000000000000000000000000'...
          '00000100038007C00FE01FF0FFFEFFFEFFFE0000000000000000000000000000' ...
          '00080007']';
   case 'ddrag'
     d = ['0000000000000000000000000000000000007FFC03800FE007C0038001000000'...
          '00000000000000000000000000000000FFFEFFFEFFFE1FF00FE007C003800100'...
          '00080007']';
   case 'add'
     cdata=[...
       2   2 NaN NaN NaN NaN NaN NaN NaN NaN   2 NaN NaN NaN NaN NaN
       2   1   2 NaN NaN NaN NaN NaN NaN   2   1   2 NaN NaN NaN NaN
       2   1   1   2 NaN NaN NaN NaN   2   2   1   2   2 NaN NaN NaN
       2   1   1   1   2 NaN NaN   2   1   1   1   1   1   2 NaN NaN
       2   1   1   1   1   2 NaN NaN   2   2   1   2   2 NaN NaN NaN
       2   1   1   1   1   1   2 NaN NaN   2   1   2 NaN NaN NaN NaN
       2   1   1   1   1   1   1   2 NaN NaN   2 NaN NaN NaN NaN NaN
       2   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   2   2   2   2   2 NaN NaN NaN NaN NaN
       2   1   1   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN NaN
       2   1   2 NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2   2 NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2 NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN NaN   2   2   2 NaN NaN NaN NaN NaN NaN NaN
    ];
       hotspot = [1 1];
       mac_curs = 0;
   case 'addpole'
     cdata=[...
       2   2 NaN NaN NaN NaN NaN   2   2   2 NaN NaN   2   2 NaN NaN
       2   1   2 NaN NaN NaN NaN   2   1   2 NaN   2   1   2 NaN NaN
       2   1   1   2 NaN NaN NaN NaN   2   1   2   1   2   2 NaN NaN
       2   1   1   1   2 NaN NaN NaN NaN   2   1   2 NaN NaN NaN NaN
       2   1   1   1   1   2 NaN NaN   2   1   2   1   2   2 NaN NaN
       2   1   1   1   1   1   2   2   1   2 NaN   2   1   2 NaN NaN
       2   1   1   1   1   1   1   2   2 NaN NaN NaN   2   2 NaN NaN
       2   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   2   2   2   2   2 NaN NaN NaN NaN NaN
       2   1   1   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN NaN
       2   1   2 NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2   2 NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2 NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN NaN   2   2   2 NaN NaN NaN NaN NaN NaN NaN
    ];
       hotspot = [1 1];
       mac_curs = 0;
   case 'addzero'
     cdata=[...
       2   2 NaN NaN NaN NaN NaN NaN   2   2   2   2   2 NaN NaN NaN
       2   1   2 NaN NaN NaN NaN   2   2   1   1   1   2   2 NaN NaN
       2   1   1   2 NaN NaN NaN   2   1   2   2   2   1   2 NaN NaN
       2   1   1   1   2 NaN NaN   2   1   2 NaN   2   1   2 NaN NaN
       2   1   1   1   1   2 NaN   2   1   2   2   2   1   2 NaN NaN
       2   1   1   1   1   1   2   2   2   1   1   1   2   2 NaN NaN
       2   1   1   1   1   1   1   2   2   2   2   2   2 NaN NaN NaN
       2   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN
       2   1   1   1   1   1   2   2   2   2   2 NaN NaN NaN NaN NaN
       2   1   1   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN NaN
       2   1   2 NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2   2 NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN
       2 NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN NaN   2   2   2 NaN NaN NaN NaN NaN NaN NaN
    ];
       hotspot = [1 1];
       mac_curs = 0;
  case 'eraser'
     cdata = [...  
     NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
       1   1   1   1   1   1   1 NaN NaN NaN NaN NaN NaN NaN NaN NaN
       1   1   2   2   2   2   2   1 NaN NaN NaN NaN NaN NaN NaN NaN
       1   2   1   2   2   2   2   2   1 NaN NaN NaN NaN NaN NaN NaN
       1   2   2   1   2   2   2   2   2   1 NaN NaN NaN NaN NaN NaN
     NaN   1   2   2   1   2   2   2   2   2   1 NaN NaN NaN NaN NaN
     NaN NaN   1   2   2   1   2   2   2   2   2   1 NaN NaN NaN NaN
     NaN NaN NaN   1   2   2   1   2   2   2   2   2   1 NaN NaN NaN
     NaN NaN NaN NaN   1   2   2   1   2   2   2   2   2   1 NaN NaN
     NaN NaN NaN NaN NaN   1   2   2   1   2   2   2   2   2   1 NaN
     NaN NaN NaN NaN NaN NaN   1   2   2   1   1   1   1   1   1   1
     NaN NaN NaN NaN NaN NaN NaN   1   2   1   2   2   2   2   2   1
     NaN NaN NaN NaN NaN NaN NaN NaN   1   1   1   1   1   1   1   1
     NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
     NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
    ];
       hotspot = [2 1];
       mac_curs = 0;
 
 case 'modifiedfleur'
      cdata = [...
      NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN 1   1   1   1   1   1   2   1   1   1   1   1   1   1   NaN
      1   2   2   2   2   2   2   2   2   2   2   2   2   2   2   1
      NaN 1   1   1   1   1   1   2   1   1   1   1   1   1   1   NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN 1   2   1   NaN NaN NaN NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN 1   NaN NaN NaN NaN NaN NaN NaN NaN
      ];
      hotspot = [8,8];
      mac_curs = 0;
 
    case 'rotate'
      cdata = [...
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN   1 NaN   1   1   1   1 NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN   1   1   1 NaN NaN NaN NaN   1    1 NaN NaN NaN
      NaN NaN NaN   1   1   1   1 NaN NaN NaN NaN NaN  NaN   1 NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN   1 NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   1 NaN
      NaN NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN   1 NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN  NaN   1 NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN   1  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN
      ];
      hotspot = [8,8];
      mac_curs = 0;
    
    case 'help'
     d = ['000040006000707C78FE7CC67EC67F0C7F987C306C3046000630033003000000'...
          'C000E000F07CF8FEFDFFFFFFFFEFFFDEFFFCFFF8FE78EF78CF7887F807F80380'...
          '00010001']';
   case 'file'
       f=fopen(fname);
       d=fread(f);
       if length(d)~=137, error('file is not the right length'), end
       d(length(d))=[];
   case 'forbidden'     
       d=['07C01FF03838703C607CC0E6C1C6C386C706CE067C0C781C38381FF007C00000'...
          '1FF03FF87FFCF87EF0FFE1FFE3EFE7CFEF8FFF0FFE1FFC3E7FFC3FF81FF00FE0'...
          '00070007']'; 
   otherwise
       Data={'Pointer',curs};
       if ~stringflag, set(fig,Data{:});end
       if nargout>0,varargout{1}=Data;end
       return
end

if mac_curs
    ind = find(d<='9');
    d(ind)=d(ind)-'0';
    ind = find(d>='A');
    d(ind)=d(ind)-'A'+10;
    bitmap = d(1:64);
    bitmap = dec2bin(bitmap,4)-'0';
    bitmap = reshape(bitmap',16,16)';
    mask = d(65:128);
    mask = dec2bin(mask,4)-'0';
    mask = reshape(mask',16,16)';
    ind = find(mask==0);
    mask(ind) = NaN;
    
    cdata = -(-mask+bitmap-1);

    hotspot_h = d(129:132);
    hotspot_h = 16.^(3:-1:0)*hotspot_h;
    hotspot_v = d(133:136);
    hotspot_v = 16.^(3:-1:0)*hotspot_v;

    hotspot = [hotspot_h, hotspot_v]+1;
end

Data={'Pointer'            ,'custom' , ...
      'PointerShapeCData'  ,cdata    , ...
      'PointerShapeHotSpot',hotspot    ...
     };
if ~stringflag, set(fig,Data{:});end
if nargout>0,varargout{1}=Data;end

% [EOF] setptr.m
