function varargout = mextglob(option,varargin)
%MEXTGLOB Module of extended objects globals.
%   VARARGOUT = MEXTGLOB(OPTION,VARARGIN)
%
%   OPTION : 'ini' , 'pref' , 'clear' 
%            'get' , 'set'  , 'is_on'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.17 $

global Def_WGlob_Struct

switch option
  case {'ini','pref'}
      defaultMode = wmachdep('read_defaultMode');
      if isempty(Def_WGlob_Struct)
          option = 'ini';
          if nargin==1 , pref = defaultMode; else , pref = varargin{1}; end
      elseif nargin==1
          return
      else
          option = 'pref';
          pref   = varargin{1};
          if isequal(Def_WGlob_Struct.initMode,pref) , return; end
      end

  case {'get','set','clear','is_on'}

  otherwise , errargt(mfilename,'Unknown Option','msg');
end

switch option
    case 'ini'
        % Initialization.
        Def_WGlob_Struct.initMode = 0;
        Def_WGlob_Struct.sizes  = [];
        Def_WGlob_Struct.colors = [];
        [sizes,colors] = wmachdep('globals');
        Def_WGlob_Struct.sizes  = sizes;
        Def_WGlob_Struct.colors = colors;
        if isempty(pref) , pref = defaultMode; end
        mextglob('pref',pref);

    case 'pref'
        allPrefMode = [1:8 , 666];
        prefMode = varargin{1};
        if     isempty(prefMode) , prefMode = defaultMode;
        elseif ischar(prefMode)   , prefMode = 'm';  % monochrome
        elseif isempty(find(prefMode==allPrefMode))
            prefMode = wmachdep('test_prefMode',prefMode);
            prefMode = defaultMode;
        end
        Def_WGlob_Struct.initMode = prefMode;
        colors = Def_WGlob_Struct.colors;
        colors = wmachdep('colors',prefMode,colors);
        Def_WGlob_Struct.colors = colors;

    case 'get'
        if isempty(Def_WGlob_Struct) , mextglob('ini'); end
        sizes  = Def_WGlob_Struct.sizes;
        colors = Def_WGlob_Struct.colors;
        nbout  = nargout;
        nbin   = nargin-1;
        for k=1:min([nbin,nbout])
            switch varargin{k}
              case 'InitMode'        , varargout{k} = Def_WGlob_Struct.initMode;
              case 'Terminal_Prop'   , varargout{k} = sizes.termProp;
              case 'ShiftTop_Fig'    , varargout{k} = sizes.figShiftTop;
              case 'Def_Btn_Height'  , varargout{k} = sizes.btnHeight;
              case 'Def_Btn_Width'   , varargout{k} = sizes.btnWidth;
              case 'Def_Txt_Height'  , varargout{k} = sizes.txtHeight;
              case 'Pop_Min_Width'   , varargout{k} = sizes.popWidth;
              case 'Sli_YProp'       , varargout{k} = sizes.sliYProp;
              case 'X_Spacing'       , varargout{k} = sizes.xSpacing;
              case 'Y_Spacing'       , varargout{k} = sizes.ySpacing;
              case 'X_Graph_Ratio'   , varargout{k} = sizes.xGraRatio;
              case 'Def_AxeFontSize' , varargout{k} = sizes.axeFontSize;
              case 'Def_TxtFontSize' , varargout{k} = sizes.txtFontSize;
              case 'Def_UicFtWeight' , varargout{k} = sizes.uicFontWeight;
              case 'Def_AxeFtWeight' , varargout{k} = sizes.axeFontWeight;
              case 'Def_TxtFtWeight' , varargout{k} = sizes.txtFontWeight;
              case 'Lst_ColorMap'    , varargout{k} = colors.lstColorMap;
              case 'Def_UICBkColor'  , varargout{k} = colors.uicBkColor;
              case 'Def_TxtBkColor'  , varargout{k} = colors.txtBkColor;
              case 'Def_EdiBkColor'  , varargout{k} = colors.ediBkColor;
              case 'Def_FraBkColor'  , varargout{k} = colors.fraBkColor;
              case 'Def_FigColor'    , varargout{k} = colors.figColor;
              case 'Def_DefColor'    , varargout{k} = colors.defColor;
              case 'Def_AxeXColor'   , varargout{k} = colors.axeXColor;
              case 'Def_AxeYColor'   , varargout{k} = colors.axeYColor;
              case 'Def_AxeZColor'   , varargout{k} = colors.axeZColor;
              case 'Def_TxtColor'    , varargout{k} = colors.txtColor;
            end
        end

    case 'set'
        if isempty(Def_WGlob_Struct) , mextglob('ini'); end
        nbin = nargin-1;
        for k=1:2:nbin
            switch varargin{k}
              case 'ShiftTop_Fig'
                Def_WGlob_Struct.sizes.figShiftTop = varargin{k+1};
              end
        end

    case 'is_on'
        varargout{1} = ~isempty(Def_WGlob_Struct);
    
    case 'clear'
        clear global Def_WGlob_Struct

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
