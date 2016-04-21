function map=idlayout(swt,number)
%IDLAYOUT Sets certain layout-defaults for the Graphical User Interface
%   to the System Identification Toolbox (ident).
%   Edit this file to your own choice of defaults.
%   You can affect the following choices:
%   1. The colors of the data and model icons. (swt = 'colors')
%      The colorcoded object tables take their colors from this
%      file. You can edit the RGB-values for each model at will.
%   2. The sizes of the axes in the different plots. (swt = 'axes')
%   3. The colors associated with the different plots.(swt = 'plotcol')
%   4. The defaults associated with the menu choices in the plot
%      windows (swt = 'figdefs', and swt = 'plotdefs'.)
%   5. The defaults for font sizes.
%
%      NOTE that these defaults are overridden by the contents of the
%      idprefs.mat file. If you save your preferences (using the
%      OPTIONS menu in the IDENT window), the current status of these
%      choices will be used at the next ident session. Using DEFUALT
%      in this options menu reverts back to the defaults defined in
%      the current m-file.

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/10 23:19:25 $

% set plotmode='white' to get plots that are like the standard
% MATLAB plots (MATLAB command 'colordef white')
% and plotmode='black' to get a black background (MATLAB
% command 'colordef black').

plotmode='white';
% plotmode='black';

if strcmp(swt,'colors')
   if get(0,'screendepth')==1
      map=ones(20,3);
   elseif strcmp(plotmode,'white')   % white background
      map=[0 0 1;...       % blue, Model #1
           0 0.5 0;...       % dark green, Model #2
           1 0 0;...       % red, Model #3
           0 0.75 0.75;...       %cyan, Model #4
           0.75 0 0.75;...       %magenta, Model #5
           0.6 0.1 1;...     % purple, Model #6
           1 0.6 0.2;...     %light brown Model #7
           1 0.9 0;...     %yellow, Model #8
           1 0.6 0.7;...     % pink, Model #9
           0.1 0 0.6;...   % 'dark blue', Model #10
           0.7 0.2 0.1;...   %brown, Model #11
           0.75 0.75 0;...       %yellow1,Model #12
           0 1 0;...     %light green Model #13
           0.5 0.5 0.5;...     %dark grey, Model #14
           0.25 0.25 0.25;...     % Model #15
           0 0.75 1;...       %sky blue, Model #16
           0.8 0.6 1;...       %, Model #17
           0.25 0.75 0.25;...       %green  Model #18
           0.75 0.75 0.75;...       % grey, Model #19
           0.75 0.75 0.2];         % khaki, Model #20
   else
      map=[1 1 0;...       % Model #1
           1 0 1;...       % Model #2
           0 1 1;...       % Model #3
           1 0 0;...       % Model #4
           0 1 0;...       % Model #5
           0 0 1;...       % Model #6
           1 0.5 0;...     % Model #7
           1 0 0.5;...     % Model #8
           0 1 0.5;...     % Model #9
           1 0.5 0.5;...   % Model #10
           1 0.8 0.8;...   % Model #11
           0.5 1 0;...     % Model #12
           1 1 0.5;...     % Model #13
           0.8 0 1;...     % Model #14
           0 0.8 1;...     % Model #15
           1 1 0;...       % Model #16
           0 0 1;...       % Model #17
           1 0 1;...       % Model #18
           1 0 0;...       % Model #19
           0 1 0];         % Model #20
      end
elseif strcmp(swt,'axes')
   if any(number==[1 2 6 13 40])  % Two axes plots without buttons
                               % Data plot, Frequency response plot
                               % Residual analysis plot and Data spectra.
      map(1,:) = [0.17 0.6025 0.75 0.28];
      map(2,:) = [0.17 0.2100 0.75 0.28];
   elseif any(number==[14 15]) % Two axes plots with buttons.
                               % Filter plot and Select data Range.
      map(1,:) = [0.13 0.6025 0.5 0.28];
      map(2,:) = [0.13 0.2100 0.5 0.28];
   elseif any(number==[9,10]) % Single plots with buttons
                                % ARX model selection,
                                % Model Order Selection
      map = [0.15 0.21 0.48 0.65];
   elseif any(number==[3]) % Model output plot

      map = [0.10 0.21 0.6 0.70];
   else                         % Single plots without buttons
                                % Zeros and poles, Noise Spectrum
      map = [0.15 0.21 0.77 0.65];
   end
elseif strcmp(swt,'plotcol')
   % COLORS ASSOCIATED WITH ALL THE PLOT WINDOWS

   % If you want different colors for the different plots
   % use the argument NUMBER when chosing the colors.
   % NUMBER is the plot number, as defined, e.g., in idlaytab.m
   % Below all plots are given the same colors.

   % col is the color of the frame surrounding the axes
   % ftcol is the color for Title and labels
   % fticol is the color for the tickmarks
   % AxesColor is the color of the axes
   % AxesFrame is the color of the axes frames in the Ident window.
   % TextColor is the color of the text in the ident window


   DefUIBgC=get(0,'DefaultUIcontrolbackgroundcolor');
   if get(0,'screendepth')==1
      % For Black and White Screens:
      col=[0 0 0]; % black
      ftcol=[1 1 1]; % white
      fticol=[1 1 1]; % white
      AxesFrame=[0 0 0]; %black
      AxesColor = [0 0 0]; % black
      TextColor = [1 1 1]; % white
   elseif strcmp(plotmode,'white')
      % For Color Screens
      col=[0.8 0.8 0.8];
      ftcol=[0 0 0]; % black
      fticol=[0 0 0]; % black
      AxesFrame=[0 0 0]; % black
      AxesColor = [1 1 1]; % white
      TextColor = [0 0 0]; % black
       fdcolor =[0.95 1 1]; %Data in the frequency Domain
      idfrdcolor=[1 1 0.7]; % IDFRD data
   else
      % For Color Screens
      col=[0.2 0.2 0.2];
      ftcol=[1 1 1]; % white
      fticol=[1 1 1]; % white
      AxesFrame=[1 1 1]; % white
      AxesColor = [0 0 0]; % black
      TextColor = [1 1 1]; % white
      fdcolor =[0 0.2 0]; %Data in the frequency Domain
      idfrdcolor=[0.2 0 0]; % IDFRD data
   end
   map=[col;ftcol;fticol;AxesColor;AxesFrame;TextColor;fdcolor;idfrdcolor];
elseif strcmp(swt,'fonts')
   % FONT SIZES ASSOCIATED WITH ALL THE WINDOWS

   % If you want different sizes for the different plots
   % use the argument NUMBER when chosing the colors.
   % NUMBER is the plot number, as defined, e.g., in idlaytab.m
   % Below all fonts are give the same size in the plot windows.

   % To affect the sizes of the texts in the uicontrols, use the
   % root property 'DefaultUIControlFontSize'
   % You may e.g. uncomment the following two lines.

   % FZ = 12; % Or any other desired fontsize.
   % set(0,'DefaultUIControlFontSize',FZ);

   scp=get(0,'screenp');
   sz1=ceil(12*72/scp);sz2=ceil(10*72/scp);
%   if scp>100,sz1=10;sz2=8;else sz1=12;sz2=10;end


   if number==100
      map=sz1; % Font size for the BEST FIT table in the model output view
   elseif number==50
      map=sz2; % Font size for the icon texts in the main IDENT window
   else
      map{1}=sz1; % Font size for Titles and Labels on plots
      map{2}='normal'; % Font weight for the same
   end
elseif strcmp(swt,'figdefs')
     % FIGURE DEFAULTS

        % ERASEMODE-DEFAULT
          map(1) = 1;  % 1 means  'normal' and 0 means 'xor'

        % LINESTYLE-DEFAULT
          map(2) = 1;  % 1 means 'All Solid' and 0 means 'Separate Linestyles'

        % BOX-DEFAULT
          map(3) = 1;  % 1 means 'Box on' and 0 means 'Box off'

        % GRID-DEFAULT
          map(4) = 0; % 1 means 'Grid on' and 0 means 'Grid off'

        % CONFIDENCE INTERVAL DEFAULTS
          map(5) = 1; % 0 means confidence interval 'off' in all plots
                      % 1 means confidence interval 'on' in RESID plot
                      %                    and 'off' in other plots
                      % 2 means confidence interval 'on' in all plots

        % ZOOM DEFAULTS
          map(6) = 1; % 0 means zoom 'off' in all plots
                      % 1 means zoom 'off' in 'Select Range',
                      %                       'Filter'
                      %                       'ARX Model Structure Selection'
                      %                       'Model Order Selection'
                      %        and 'on' in the other plots
                      % 2 means zoom 'off' in 'ARX Model Structure Selection'
                      %                       'Model Order Selection'
                      %        and 'on' on the other plots
                      % 3 means zoom 'on' in all plots

          map=map(:);maptemp=map*ones(1,15);
          if map(5)==1,maptemp(5,:)=zeros(1,15);maptemp(5,6)=1;end
          if map(5)==2,maptemp(5,:)=ones(1,15);end
          if map(6)==1,
             maptemp(6,:)=ones(1,15);maptemp(6,[9,10,14,15])=[0,0,0,0];
          end
          if map(6)==2,
             maptemp(6,:)=ones(1,15);maptemp(6,[9,10])=[0,0];
          end
          if map(6)==3,maptemp(6,:)=ones(1,15);end
          map=maptemp;
elseif strcmp(swt,'plotdefs')

     % PLOT DEFAULTS

        % FREQUENCY PLOT DEFAULTS
          map(1) = 1; % 1 means that the frequency unit is rad/sec
                      % 2 means that the frequency unit is Hz

          map(2) = 2; % 1 means that the frequency scale is linear
                      % 2 means that the frequency scale is logarithmic

          map(3) = 2; % 1 means that the amplitude scale is linear
                      % 2 means that the amplitude scale is logarithmic

       % MODEL OUTPUT PLOT DEFAULTS

         map(4) = 5;  % This is the number of samples ahead that are predicted

         map(5) = 1;  % 1 means Comparsion of simulated and measured output
                      % 2 means Comparsion of predicted and measured output

         map(6) = 0;  % 0 means that measured and simulated/predicted curves
                      % are shown together,
                      % 1 means that their difference is ploted

       % TRANSIENT RESPONSE DEFAULTS

         map(7) = 1;  % 1 means Step Response. 2 means Impulse response

         map(8) = 1;  % 1 means a line plot. 2 means a stem plot

         map(9) = 40; % Number of samples for which the response is
                      % calculated

       % RESID PLOT DEFAULT

         map(10) = 20; % Number of samples for which the correlation
                       % functions are calculated

       % SPECTRAL PLOTS

         map(11) = 2;  % 1 means spa options, 2 means fft

      % TIME PLOT DEFAULTS

        map(12) = 1;  % 1  means staircase input plot (piecewise constant)
                      % 2  means regular plot (piecewise linear)

end