function varargout = dwtmode(option,varargin)
%DWTMODE Discrete wavelet transform extension mode.
%   DWTMODE sets the signal or image extension mode for
%   discrete wavelet and wavelet packet transforms.
%   The extension modes represent different ways of handling
%   the problem of border distortion in the analysis.
%
%   DWTMODE or DWTMODE('status') display the current mode.
%   ST = DWTMODE or ST = DWTMODE('status') display and
%   return the current mode.
%   ST = DWTMODE('status','nodisp') returns the current mode
%   and does not display the text.
%
%   DWTMODE('sym') or DWTMODE('symh') sets the DWT mode to 
%   symmetric-padding (half-point): boundary value symmetric
%   replication - default mode.
%
%   DWTMODE('symw') sets the DWT mode to symmetric-padding
%   (whole-point): boundary value symmetric replication.
%
%   DWTMODE('asym') or DWTMODE('asymh') sets the DWT mode to 
%   antisymmetric-padding (half-point): boundary value 
%   antisymmetric replication.
%
%   DWTMODE('asymw') sets the DWT mode to antisymmetric-padding
%   (whole-point): boundary value antisymmetric replication.
%
%   DWTMODE('zpd') sets the DWT mode to zero-padding
%
%   DWTMODE('spd') or DWTMODE('sp1') sets the DWT mode 
%      to smooth-padding of order 1 (first derivative
%      interpolation at the edges).
%
%   DWTMODE('sp0') sets the DWT mode to smooth-padding
%      of order 0 (constant extension at the edges). 
%
%   DWTMODE('ppd') sets the DWT mode to periodic-padding
%      (periodic extension at the edges).
%
%   The DWT associated with these eight modes is slightly  
%   redundant. But IDWT ensures a perfect reconstruction for any
%   of the five previous modes whatever is the extension mode 
%   used for DWT.
%
%   DWTMODE('per') sets the DWT mode to periodization.
%        
%   This mode produces the smallest length wavelet decomposition.
%   But, the extension mode used for IDWT must be the same to
%   ensure a perfect reconstruction.
%   Using this mode, DWT and DWT2 produce the same results as 
%   the obsolete functions DWTPER and DWTPER2, respectively.
%
%   All functions and GUI tools that use the DWT (1-D & 2-D) or
%   Wavelet Packet (1-D & 2-D) use the specified DWT extension mode.
%
%   DWTMODE updates a global variable allowing the use of these
%   six signal extensions. The extension mode should only 
%   be changed using this function. Avoid changing the global 
%   variable directly.
%
%   --------------------------------------------------------------
%   The default mode is loaded from the file DWTMODE.DEF
%   if it exists. If not, the file DWTMODE.CFG 
%   (in the "toolbox/wavelet/wavelet" directory) is used.
%   DWTMODE('save',mode) saves "mode" as new default mode
%   in the file DWTMODE.DEF (all the files named DWTMODE.DEF 
%   are deleted before saving).
%   DWTMODE('save') is equivalent to DWTMODE('save',currentMode).
%   --------------------------------------------------------------
%
%   See also DWT, DWT2 ,IDWT, IDWT2, WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.16.4.2 $

% Internal options: 'load', 'save', 'get', 'set', 'clear'
 
global DWT_Attribute
if nargin==0 , option = 'status'; else , option = lower(option); end

switch option
    case 'load'       
        try
           load('dwtmode.def','-mat');
           DWT_Attribute = dwt_default_Attrb;
        catch
           try
             load('dwtmode.cfg','-mat');
             DWT_Attribute = dwt_default_Attrb;
           catch
             DWT_Attribute = ...
                  struct('extMode','sym','shift1D',0,'shift2D',[0,0]);
           end
        end

    case 'save'
        if nargin<2
            if ~isempty(DWT_Attribute)
                extM = DWT_Attribute.extMode;
            else
                dwtmode('load');
                extM = DWT_Attribute.extMode;
            end
        else
            extM = varargin{1};
        end
        if isequal(extM,'zpd')  | ...
           isequal(extM,'sym')  | isequal(extM,'symh')  | ...
           isequal(extM,'asym') | isequal(extM,'asymh') | ...
           isequal(extM,'symw') | isequal(extM,'asymw') | ...
           isequal(extM,'sp0')  | isequal(extM,'spd')   | ...
           isequal(extM,'sp1')  | isequal(extM,'ppd')   | isequal(extM,'per')

            try
              extM = trueExtName(extM);  
              dwt_default_Attrb = ...
                       struct('extMode',extM, 'shift1D',0,'shift2D',[0,0]);
              namefileSave = 'dwtmode.def';
              s = which(namefileSave,'-all');
              try , delete(s{:}); end
              save(namefileSave,'dwt_default_Attrb');
              msg = strvcat(sprintf('Saving DWT Extension in %s !', namefileSave),...
                            sprintf('Default DWT Mode is : %s', extM));
              msgval = 1;
            catch
              msg = ['Save DWT Extension Mode failed !'];
              msgval = 2;
            end
        else
           msg = ['Invalid DWT Extension Mode !'];
           msgval = 2;
        end
        if isequal(get(0,'Userdata'),'testWTBX') , msgval = 3; end
        switch msgval
          case 1 , wwarndlg(msg,'Save DWT Extension Mode','modal');
          case 2 , errordlg(msg,'Save DWT Extension Mode','modal');
          case 3 , sep = repmat('-',1,size(msg,2)+2);
                   disp(strvcat(sep,msg,sep));
        end

    case 'set'
        for k = 1:2:nargin-1
            switch varargin{k}
              case {'extMode','mode'} ,
                  extM = trueExtName(varargin{k+1});
                  DWT_Attribute.extMode = extM;
              case 'shift1D' , DWT_Attribute.shift1D = mod(varargin{k+1},2);
              case 'shift2D' , DWT_Attribute.shift2D = mod(varargin{k+1},2);
              otherwise ,
                errargt(mfilename,'Invalid field name','msg');
                error('*');
            end
        end

    case 'get'
        if isempty(DWT_Attribute) , wtbxmngr('ini'); end
        switch nargout
            case 1 , varargout = {DWT_Attribute};
            case 2 , varargout = {...
                        DWT_Attribute.extMode , ...
                        DWT_Attribute.shift1D};
            case 3 , varargout = {...
                        DWT_Attribute.extMode , ...
                        DWT_Attribute.shift1D , ...
                        DWT_Attribute.shift2D};
        end
        
    case 'clear'
        clear global DWT_Attribute

    case {'zpd','sym','symh','symw','asym','asymh','asymw',...
          'sp0','spd','sp1','ppd','per','status'}
        % Check arguments.
        nbIn  = nargin;
        nbOut = nargout;
        if nbIn > 2 ,      error('Too many input arguments.');
        elseif nbOut > 1 , error('Too many output arguments.');
        end
        if isempty(DWT_Attribute) , wtbxmngr('ini'); end
        option = trueExtName(option);
        if ~isequal(option,'status') & ~isequal(DWT_Attribute.extMode,option)
            DWT_Attribute.extMode = option;
            numMsg = 1;
        else
            numMsg = 2;
        end
        if nbIn<2 , dispMessage(numMsg,DWT_Attribute.extMode); end
        if nbOut==1 , varargout{1} = DWT_Attribute.extMode; end

    otherwise
        errargt(mfilename,'Unknown Extension Mode','msg');
        error('*');
end


%----------------------------------------------------------------------------%
% Internal Function(s)
%----------------------------------------------------------------------------%
function dispMessage(num,mode)
if num<2
    disp(' ');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    disp('!  WARNING: Change DWT Extension Mode  !');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
end
% Display Extension Mode.
msg = ['DWT Extension Mode: '];
switch mode
    case 'zpd' ,            msg = [msg 'Zero Padding'];
    case {'sym','symh'} ,   msg = [msg 'Symmetrization (half-point)'];
    case 'symw' ,           msg = [msg 'Symmetrization (whole-point)'];
    case {'asym','asymh'} , msg = [msg 'Antisymmetrization (half-point)'];
    case 'asymw' ,          msg = [msg 'Antisymmetrization (whole-point)'];
    case 'sp0' ,            msg = [msg 'Smooth Padding of order 0'];
    case {'spd','sp1'} ,    msg = [msg 'Smooth Padding of order 1'];
    case 'ppd' ,            msg = [msg 'Periodized Padding'];    
    case 'per' ,            msg = [msg 'Periodization'];
end
n = length(msg)+8;
c = '*';
s = c(ones(1,n));
msg = strvcat(' ',s,[c c '  ' msg '  ' c c],s,' ');
disp(msg);
%----------------------------------------------------------------------------%
function output = trueExtName(input)
switch input
    case {'sp1','spd'}  , output = 'spd';
    case {'sym','symh'} , output = 'sym';
    case {'asym','asymh'} , output = 'asym';
    otherwise , output = input;
end
%----------------------------------------------------------------------------%
