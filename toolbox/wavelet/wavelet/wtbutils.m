function varargout = wtbutils(option,varargin)
%WTBUTILS Wavelet Toolbox (Resources) Utilities.
%   OUT1 = wtbutils(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-May-99.
%   Last Revision: 06-Mar-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 19:49:32 $

switch option
  case 'colors'

    % Miscellaneous Colors.
    %----------------------
    DefColor = mextglob('get','Def_DefColor');
    white = isequal(DefColor(1),'w');

    type = varargin{1};
    switch type
      case 'sig'  % TYPE = 'sig'  - signal color.
        varargout{1} = [1 0 0];     % Red

      case 'ssig' % TYPE = 'ssig' - synthesized signal color.
        varargout{1} = [1 1 0];     % Yellow
        if white , varargout{1} =  [1 1 0]/1.1; end;

      case 'stem' % 
        varargout{1} = [1 1 0];     % Yellow
        if white , varargout{1} =  [1 1 0]/1.1; end;

      case 'app'  % TYPE = 'app'  - approximations colors.
        % in2 = NB Colors or 'flag'
        %--------------------------
        varargout{1} = [0 1 1];   % Cyan
        if white
            % varargout{1} = varargout{1}/2; % Dark Cyan
            varargout{1} = [0 0 1]/1.05;     % Dark Blue
        end;

        if length(varargin)>1
          if ischar(varargin{2}) , return; end
          nbCOL = varargin{2};
          varargout{1} = wtbutils('colors','scaled',varargout{1},nbCOL);
          if ~white , varargout{1}(:,2) = 0.75; end
        end

      case 'det'  % TYPE = 'det'  - details colors.
        % in2 = NB Colors or 'flag'
        %--------------------------
        varargout{1} =  [0 1 0];    % Green
        if white
            varargout{1} = varargout{1}/2; % Dark Green
        end;
        if length(varargin)>1
          if ischar(varargin{2}) , return; end
          varargout{1} = wtbutils('colors','scaled',varargout{1},varargin{2});
        end

      case {'res'} 
        varargout{1} = [1 0.70 0.28]; % Orange

      case 'snod' % TYPE = 'snod' - synthesized node color. 
        varargout{1} = [1 0 1];     % Magenta

      case 'scaled'  % TYPE = 'scaled' - scaled colors
        % in2 = basic color [R G B]
        % in3 = NB Colors
        %--------------------------
        baseCOL = varargin{2};
        nbCOL   = varargin{3};
        out1 = baseCOL;
        dcol = (1-baseCOL);
        if sum((0<dcol) & (dcol<1))==0
            dcol = dcol/nbCOL;
            out1 = out1(ones(1,nbCOL),:);
            for k=1:nbCOL-1
                 out1(k,:) = out1(k,:)+dcol.^(1/(nbCOL+1-k));
            end
            out1 = max(0,min(out1,1));
        else
            dcol(dcol==1)= 0;
            dcol = dcol/max(1,nbCOL-1);
            out1 = [0:nbCOL-1]'*dcol+baseCOL(ones(1,nbCOL),:);
            out1 = flipud(out1);
        end
        varargout{1} = out1;

      case 'legend'
        varargout = {[1 1 0],[1 0 1],[0 1 1]};

      case {'linTHR','title','wfilters','coefs','linDW2D','arrow'}
        varargout = {[1 1 0]};

      case {'tree'}
        varargout = {[1 1 1],[1 1 0]};

      case {'cw1d'}
        if length(varargin)<2
            varargout = {[1 0 0],[0 1 0],[0 1 1]}; % Red, Green, Cyan
        end
        choice = varargin{2};
        switch choice
          case 'sig' , varargout{1} = [1 0 0];   % Red
          case 'lin' , varargout{1} = [0 1 0];   % Green
          case 'spy' , varargout{1} = [0 1 1];   % Cyan
        end

      case {'dw1d'}
        choice = varargin{2};
        switch choice
          case 'sepcfs' , varargout{1} = [1 0 1];  % Magenta
        end

      case {'dw2d'}
        varargout = {[1 1 0],[1 1 1],[0 1 0]};

      case {'sw2d'}
        choice = varargin{2};
        switch choice
          case 'histRES' , varargout{1} = wtbutils('colors','res');  % Orange
        end

      case {'wp1d'}
        choice = varargin{2};
        switch choice
          case 'node'  , varargout{1} = [0 1 1];  % Cyan
          case 'hist'  , varargout{1} = [1 0 1];  % Magenta
          case 'recons', varargout{1} = wtbutils('colors','res');  % Orange
        end

      case {'wp2d'}
        choice = varargin{2};
        switch choice
          case 'hist' , varargout{1} = [1 0 1];  % Magenta
        end

      case {'wdre'}
        varargout{1} = struct( ...
           'sigColor',[1 0 0],'denColor',[1 0 0],'appColor',[0 1 1], ...
           'detColor',[0 1 0],'cfsColor',[0 1 0],'estColor',[1 1 0]  ...
           );

      otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');

      end
        
  case 'wputils'
    Def_AxeFontSize = mextglob('get','Def_AxeFontSize');
    type = varargin{1};
    type = type(1);
    if length(varargin)>1 , axe_xcol = varargin{2}; end
    switch type
      case 'p'
        %*************************%
        %** OPTION = 'plottree' **%
        %*************************%
        % out1 = txt_color
        % out2 = lin_color
        % out3 = ftn_size
        %------------------------
        varargout = {abs(axe_xcol-[0 0 1]),axe_xcol,Def_AxeFontSize};

      case 't'
        %************************%
        %** OPTION = 'tree_op' **%
        %************************%
        % out1 = txt_color
        % out2 = sel_color
        % out3 = nod_color
        % out4 = ftn_size
        %------------------------
        initMode = mextglob('get','InitMode');
        varargout{1} = abs(axe_xcol-[0 0 1]);
        if isequal(initMode,666)
            varargout{2} = [1 0 0];
            varargout{3} = wtbutils('colors','wp1d','node');
        elseif axe_xcol==[1 1 1]
            varargout{2} = [0 1 0];
            varargout{3} = wtbutils('colors','wp1d','node');
        else
            varargout{2} = [1 0 0];
            varargout{3} = [0.2 0.2 0.2];
        end
        varargout{4} = Def_AxeFontSize;

      case 's'
        %************************%
        %** OPTION = 'ss_node' **%
        %************************%
        % out1 = txt_color
        % out3 = pack_color
        % out3 = ftn_size
        %------------------------
        col = wtbutils('colors','snod');
        varargout = {col,col,Def_AxeFontSize};
    end

end
