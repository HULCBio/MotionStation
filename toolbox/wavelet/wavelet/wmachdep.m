function varargout = wmachdep(option,varargin)
%WMACHDEP Machine dependent values.
%   VARARGOUT = WMACHDEP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Feb-1998.
%   Last Revision: 03-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 19:42:19 $

switch option
    case 'read_defaultMode'
      varargout{1} = 3;  % Gray Figures.
      return
    case 'test_prefMode'
      allPrefMode = [1:8 , 666];
      if isempty(find(varargin{1}==allPrefMode))
          varargout{1} = wmachdep('read_defaultMode');
      else
          varargout{1} = varargin{1};
      end
      return
end

scrSize = get(0,'ScreenSize');
machine = computer;
machine = machine(1:3);

switch option   
    case 'globals'
        % Globals: Sizes and Colors
        %---------------------------
        if scrSize(4)<600
            sizes.btnHeight = 16;
            sizes.btnWidth  = 60;
            sizes.popWidth  = 50;
            sizes.xSpacing  = 2;
            sizes.ySpacing  = 2;
            switch machine
                case 'PCW' , sizes.axeFontSize = 8; sizes.txtFontSize = 8;
                otherwise  , sizes.axeFontSize = 8; sizes.txtFontSize = 8;
            end
            sizes.axeFontSize = 8;
            sizes.txtFontSize = 8;
            sizes.uicFontWeight = 'normal';
            sizes.axeFontWeight = 'normal';
            sizes.txtFontWeight = 'normal';
            sizes.xGraRatio   = 0.71;

        elseif scrSize(4)<700
            if strcmp(machine,'MAC')
                sizes.btnHeight = 20;
            else
                sizes.btnHeight = 18;
            end
            sizes.btnWidth = 60;
            sizes.popWidth = 60;
            sizes.xSpacing = 3;
            sizes.ySpacing = 3;
            switch machine
                case 'PCW' , sizes.axeFontSize = 8; sizes.txtFontSize = 8;
                otherwise  , sizes.axeFontSize = 9; sizes.txtFontSize = 9;
            end
            sizes.uicFontWeight = 'normal';
            sizes.axeFontWeight = 'normal';
            sizes.txtFontWeight = 'normal';
            sizes.xGraRatio   = 0.72;

        elseif scrSize(4)<1200
            sizes.btnHeight = 22;
            sizes.btnWidth  = 80;
            sizes.popWidth  = 60;
            sizes.xSpacing  = 8;
            sizes.ySpacing  = 5;
            switch machine
                case 'PCW' , sizes.axeFontSize = 8; sizes.txtFontSize = 8;
                otherwise  , sizes.axeFontSize = 9; sizes.txtFontSize = 9;
            end
            sizes.uicFontWeight = 'bold';
            sizes.axeFontWeight = 'bold';
            sizes.txtFontWeight = 'bold';
            sizes.xGraRatio   = 0.71;

        else
            sizes.btnHeight = 22;
            sizes.btnWidth  = 90;
            sizes.popWidth  = 70;
            sizes.xSpacing  =  8;
            sizes.ySpacing  =  6;
            switch machine
                case 'PCW' , sizes.axeFontSize = 8; sizes.txtFontSize = 8;
                otherwise  , sizes.axeFontSize = 9; sizes.txtFontSize = 9;
            end
            sizes.uicFontWeight = 'bold';
            sizes.axeFontWeight = 'bold';
            sizes.txtFontWeight = 'bold';
            sizes.xGraRatio     = 0.71;

        end
        sizes.txtHeight   = 16;
        sizes.sliYProp    = 2/3;
        colors.uicBkColor = get(0,'DefaultUicontrolBackgroundcolor');
        switch machine
            case 'PCW'
                sizes.termProp     = scrSize(3:4);
                sizes.figShiftTop  = 40;
                if scrSize(4)>=1200 , sizes.figShiftTop  = 55; end
                colors.uicBkColor = 0.7529*[1 1 1];
                colors.txtBkColor = 0.6*[1 1 1];
                colors.fraBkColor = colors.uicBkColor;

            case 'MAC'
                sizes.termProp    = scrSize(3:4);
                sizes.figShiftTop = 40;
                colors.txtBkColor = [0.90 0.90 0.90];
                colors.fraBkColor = [0.77 0.77 0.77];
                
            otherwise
                sizes.termProp    = get(0,'TerminalDimension');
                sizes.figShiftTop = 55;
                colors.txtBkColor = [0.90 0.90 0.90];
                colors.fraBkColor = colors.uicBkColor;
        end
        colors.ediBkColor  = [1 1 1];
        colors.lstColorMap = ...
                strvcat(...
                        'pink','cool','gray','hot','jet','bone',      ...
                        'copper','hsv','prism','1 - pink','1 - cool', ...
                        '1 - gray','1 - hot','1 - jet','1 - bone',    ...
                        'autumn ','spring','winter','summer'          ...
                        );
        varargout = {sizes , colors};

    case 'colors'
        % Globals: Colors
        %-----------------
        prefMode = varargin{1};
        colors   = varargin{2};
        colors.defColor = 'white';
        switch prefMode
            case {'white','black','none'}
                colors.defColor = prefMode;

            case {1,2,3,4,5}
                colors.defColor = 'black';
                switch prefMode
                    case 1   , colors.figColor = [0 0 0];
                    case 2   , colors.figColor = [0.2 0.3 0.5];
                    case 3   , colors.figColor = [0.5 0.5 0.5];
                    case 4   , colors.figColor = [0.5 0.3 0.2];
                    case 5   , colors.figColor = [0.3 0.5 0.2];
                end
                xyz_Color = 'w';
                if strcmp(machine,'PCW')
                    colors.uicBkColor = 0.7529*[1 1 1];
                    colors.txtBkColor = 0.6*[1 1 1];
                    colors.fraBkColor = colors.uicBkColor;

                elseif prefMode==1 | prefMode==3 | prefMode==9
                    colors.txtBkColor = [0.90 0.90 0.90];
                    colors.fraBkColor = colors.uicBkColor;
 
                else
                    colors.txtBkColor = colors.figColor.^0.3;
                    colors.fraBkColor = colors.figColor.^0.4;
                end

            case {666}
                colors.defColor = 'white';
                colors.figColor = [0.6 0.6 0.6];
                xyz_Color = 'k';
                colors.uicBkColor = 0.7529*[1 1 1];
                colors.txtBkColor = 0.7*[1 1 1];
                colors.fraBkColor = colors.uicBkColor;

            case {6,7,8}
                colors.defColor = 'white';
                if     prefMode==6 , colors.figColor = 'w';
                elseif prefMode==7 , colors.figColor = [1 0.9 0.8];
                elseif prefMode==8 , colors.figColor = [0.9 0.9 1];
                end
                xyz_Color = 'k';
                if strcmp(machine,'PCW')
                    colors.txtBkColor = [247/255 247/255 247/255];
                    colors.fraBkColor = colors.uicBkColor;
                elseif prefMode==6
                    colors.txtBkColor = [0.90 0.90 0.90];
                    colors.fraBkColor = [0.77 0.77 0.77];
                else
                    colors.txtBkColor = colors.figColor.^4;
                    colors.fraBkColor = colors.figColor.^3;
                end

            case 'm'    % monochrome
                colors.figColor = get(0,'DefaultFigureColor');
                xyz_Color = 'w';
                colors.txtBkColor = [0.90 0.90 0.90];
                colors.fraBkColor = [0.77 0.77 0.77];
        end
        txt_Color = xyz_Color;
        colors.axeXColor = xyz_Color;
        colors.axeYColor = xyz_Color;
        colors.axeZColor = xyz_Color;
        colors.txtColor  = txt_Color;
        varargout{1} = colors;

    case 'fontsize'
        switch varargin{1}
            case 'normal'
                if     scrSize(4)<600 , siz = 16;
                elseif scrSize(4)<700 , siz = 18;
                elseif scrSize(4)<800 , siz = 20;
                else                  , siz = 20;
                end
                if nargin>2
                    % in3 = font threshold or value threshold
                    % in4 = value (optional).
                    %-----------------------------------------
                    if nargin==3
                        siz = min(siz,varargin{2});
                    elseif nargin==4
                        if varargin{3}>varargin{2} , siz = siz-2; end
                    end
                end

            case 'winfo'
                switch machine
                   case {'SOL','SUN'} ,        siz = 12;

                   case {'PCW'}
                       if     scrSize(4)<500 , siz =  8;
                       elseif scrSize(4)<700 , siz =  9;
                       else                  , siz = 10;
                       end

                   otherwise ,                 siz = 10;
                end
        end
        CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
        StdScrPixPerInch = 72;
        RatScrPixPerInch = StdScrPixPerInch / CurScrPixPerInch;
        varargout{1}     = floor(RatScrPixPerInch*siz);

    case 'center_txt'
        if scrSize(4)<700
            varargout{1} = strvcat('Center','  On  ');
        else
            varargout{1} = strvcat(' ','Center On',' ');
        end

    case 'btnZoomAxes'
        if scrSize(4)>=1200
            varargout{1} = 20/36;
        else
            varargout{1} = 15/36;
        end

    case 'PCWDepSize'
        % in2 = [mulPCW mulOthers].
        % in3 = vector of sizes.
        %--------------------------
        switch machine
            case 'PCW' , ind = 1;
            otherwise  , ind = 2;
        end
        varargout{1} = varargin{1}(ind)*varargin{2};

    case 'markersize'
        switch machine
          case {'SUN','SOL'} , MSize = 25;
          otherwise , MSize = 24;
        end
end
