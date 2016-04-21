function varargout = wtbxmngr(option,varargin)
%WTBXMNGR Wavelet Toolbox manager.
%   WTBXMNGR or WTBXMNGR('version') displays the current
%   version of the Toolbox mode (Version 1.x vs. 2.x).
% 
%   WTBXMNGR('V1') or WTBXMNGR('v1') sets the
%   wavelet packets management mode to Version 1.x
%   (This is the obsolete mode).
% 
%   WTBXMNGR('V2') or WTBXMNGR('v2') sets the
%   wavelet packets management mode to Version 2.x
%   The wavelet packets objects are used (see WPTREE).
%   WTBXMNGR('V3'), WTBXMNGR('v2') or WTBXMNGR('CurrentVersion') 
%   sets the wavelet packets management mode to Current
%    Version(V3.0) which is the same as in Version 2.x.
%
%   WTBXMNGR('LargeFonts') sets the size of the next created
%   figures in such a way that they can accept Large Fonts. 
%
%   WTBXMNGR('DefaultSize') restores the default figure size 
%   for the next created figures.
%
%   WTBXMNGR('FigRatio',ratio) changes the size of the next 
%   created figures multiplying the default size by "ratio", 
%   with 0.75 <= ratio <= 1.25.
%
%   WTBXMNGR('FigRatio') returns the current ratio value.

% INTERNAL OPTIONS:
%-----------------
%   OPTION = 'load' , 'ini' , 'is_on' , 'get' , 'clear'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Feb-98.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/03/15 22:43:34 $

global WTBX_Glob_Info Wavelets_Info DWT_Attribute

%----------------------%
% Wavelets Structures. %
%------------------------------------------%
% WTBX_Glob_Info is a structure.
% WTBX_Glob_Info = ...
%   struct(...
%     'name'        char = 'WTBX'
%     'version'     integer
%     'objVersion'  integer
%     );
%------------------------------------------%
% Wavelets_Info is a  structure array 
% with size = [nb_fam 1]
%
% Wavelet_Struct =
%   struct(...
%     'index'           integer
%     'familyName'      string
%     'familyShortName' string
%     'type'            integer
%     'tabNums'         matrix of string
%     'typNums'         string
%     'file'            string
%     'bounds'          string
%     );
%------------------------------------------%
% DWT_Attribute is a structure.
%   struct(...
%     'extMode'   'sym' , 'zpd' , 'spd' ...
%     'shift1D'   integer
%     'shift2D'   [integer integer]
%     );
%------------------------------------------%

okInit = ...
    ~isempty(WTBX_Glob_Info) && ...
    ~isempty(Wavelets_Info)  && ...
    ~isempty(DWT_Attribute);

if nargin==0 , option = 'version'; end 
switch lower(option)
    case 'load'
      switch nargin
        case 1
          fileName = 'wtbx_gbl.v1';
          s = which(fileName,'-all');
          if ~isempty(s) ,
               VersfileName = 'wtbx_gbl.v1';
          else
               VersfileName = 'wtbx_gbl.v3';
          end
           
        case 2
          wtbxVER = varargin{1};
          switch wtbxVER
             case {'v1','V1'} , VersfileName = 'wtbx_gbl.v1';
             otherwise        , VersfileName = 'wtbx_gbl.v3';
          end
      end
      try
         load(VersfileName,'-mat');
      catch
         WTBX_Glob_Info.name       = 'WTBX';
         WTBX_Glob_Info.version    = 3.0;
         WTBX_Glob_Info.objVersion =   1;
      end
      if nargout>0
          varargout{1} = ['V' int2str(WTBX_Glob_Info.objVersion+1)];
      end

    case 'ini'
      if okInit , return; end
      wtbxmngr('load');
      wavemngr('load');
      dwtmode('load');

    case 'is_on'
      varargout{1} = okInit;

    case 'get'
      if ~okInit , wtbxmngr('ini'); end
      nbout   = nargout;
      nbin    = nargin-1;
      for k=1:min([nbin,nbout])
          switch varargin{k}
            case 'AppName'
              varargout{k} = [WTBX_Glob_Info.name '_V' ...
                              sprintf('%2.1f',WTBX_Glob_Info.version)];            
            case 'name'       , varargout{k} = WTBX_Glob_Info.name;            
            case 'version'    , varargout{k} = WTBX_Glob_Info.version;
            case 'objVersion' ,
              okObj = ~isempty(what('@wptree'));
              varargout{k} = WTBX_Glob_Info.objVersion & okObj;
            case 'wavelets'   , varargout{k} = Wavelets_Info;
            case 'dwtAttrb'   , varargout{k} = DWT_Attribute;
          end
      end

    case 'version'
      objVers  = wtbxmngr('get','objVersion');
      wtbxVers = wtbxmngr('get','version');
      switch objVers
          case 0    , numVers = objVers + 1;
          otherwise , numVers = wtbxVers;
      end
      numVers = ['V' int2str(numVers)];
      if nargin<2 , dispMessage(numVers); end
      if nargout>0 , varargout{1} = numVers; end

    case 'v1'
      clear global WTBX_Glob_Info
      fileName = 'wtbx_gbl.v3';
      s = which(fileName);
      n = findstr(s,'wavedemo');
      addV1_path = [s(1:n-1) 'waveobsolete'];
      path(addV1_path,path);
      wtbxVers = wtbxmngr('load','V1');
      if nargin==1 , dispMessage(wtbxVers,'warning'); end
      if nargout>0 , varargout{1} = wtbxVers; end

    case {'v2','v3','currentversion'}
      clear global WTBX_Glob_Info
      fileName = 'wtbx_gbl.v1';
      s = which(fileName,'-all');
      if ~isempty(s)
         for k = 1:size(s,1)
            d = s{k};
            n = findstr(d,fileName);
            rmpath(d(1:n-1));
         end
     end
     wtbxVers = wtbxmngr('load','V3');
     if nargin==1 , dispMessage(wtbxVers,'warning'); end
     if nargout>0 , varargout{1} = wtbxVers; end

    case {'largefonts','defaultsize'}
      if isequal(lower(option),'largefonts')
          CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
          StdScrPixPerInch = 96;
          RatScrPixPerInch = CurScrPixPerInch / StdScrPixPerInch;
      else
          RatScrPixPerInch = 1;
      end
      wtbxmngr('figratio',RatScrPixPerInch);

    case 'figratio'
      if length(varargin)>0  
        ResizeRatioWTBX_Fig = varargin{1};
        dispMSG = -1;  % No display for correct value
      else
        ResizeRatioWTBX_Fig = getappdata(0,'ResizeRatioWTBX_Fig');
        if isempty(ResizeRatioWTBX_Fig) , ResizeRatioWTBX_Fig = 1; end
        dispMSG = 0;  % No display for correct value
      end
      OK = length(ResizeRatioWTBX_Fig)==1 && isnumeric(ResizeRatioWTBX_Fig) && ...
           isreal(ResizeRatioWTBX_Fig);
      if OK
          if     ResizeRatioWTBX_Fig<0.75 , ResizeRatioWTBX_Fig = 0.75; dispMSG = 1; 
          elseif ResizeRatioWTBX_Fig>1.25 , ResizeRatioWTBX_Fig = 1.25; dispMSG = 2;             
          end
          
      else
          dispMSG = 3; 
          oldFigRatio = getappdata(0,'ResizeRatioWTBX_Fig');
          if isempty(oldFigRatio) , oldFigRatio = 1; end
          ResizeRatioWTBX_Fig = oldFigRatio; 
      end
      setappdata(0,'ResizeRatioWTBX_Fig',ResizeRatioWTBX_Fig);
      if dispMSG>0
          msg = strvcat(...
              'Invalid value for fig_RATIO',...
              'choose a value between 0.75 and 1.25', ...
              ['current value is: ' num2str(ResizeRatioWTBX_Fig) ]);
          warndlg(msg)                   
      elseif dispMSG==0
          msg = strvcat(...
              'The current value for Wavelet Toolbox', ...
              ['Figure Ratio is :' num2str(ResizeRatioWTBX_Fig)]);
          msgbox(msg)                   
      end
  
    case 'clear'
      clear global WTBX_Glob_Info
      wavemngr('clear');
      dwtmode('clear');
end


%----------------------------------------------------------------------------%
% Internal Function(s)
%----------------------------------------------------------------------------%
function dispMessage(wtbxVers,dummy)

% Display Extension Mode.
msg = ['Wavelet Toolbox Version: V3'];
switch wtbxVers
    case {'v1','V1'}
       msg = strvcat(msg,...
          'The Wavelet Toolbox is now compatible with versions 1.x',...
          'Obsolete functions are now available.');
      
    case {'v2','V2','v3','V3'}

end
sizeMSG = size(msg);
nbLINES = sizeMSG(1);
lenMSG  = sizeMSG(2);
n = lenMSG+8;
b = '  ';
c = '*';
s = c(ones(1,n));
c  = c(ones(1,nbLINES),:); b  = b(ones(1,nbLINES),:);
msg1 = strvcat(' ',s,[c c b msg b c c],s,' ');

clc;
if nargin>1
    dummy  = '!  WARNING: Changed Wavelet Toolbox Version  !';
    lenDUM = length(dummy);
    addLEN = floor((lenMSG-lenDUM)/2);
    disp(' ');
    disp([blanks(addLEN), '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!']);
    disp([blanks(addLEN), '!  WARNING: Changed Wavelet Toolbox Version  !']);
    disp([blanks(addLEN), '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!']);
end

disp(msg1);
%----------------------------------------------------------------------------%
