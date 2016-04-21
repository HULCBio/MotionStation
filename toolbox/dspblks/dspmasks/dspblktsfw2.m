function varargout = dspblktsfw2(action, varargin)
% DSPBLKTSFW Signal Processing Blockset Triggered Signal From Workspace block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.12.4.4 $ $Date: 2004/04/12 23:07:29 $

if nargin==0, action = 'dynamic'; end

fullblk       = getfullname(gcb);
FromWorks_blk = [fullblk ['/From',sprintf('\n'),'Workspace']];
ExtendOutput  = get_param(fullblk, 'OutputAfterFinalValue');

switch action
case 'icon'
   % Draw trigger icons:
   TriggerType = varargin{1};

   [px,py] = dsptrigicon(fullblk,TriggerType);
   varargout={px,py};

case 'init'
 % Change Simulink FromWorkspace block setting only if needed
 if ~strcmp(get_param(FromWorks_blk, 'OutputAfterFinalValue'), ExtendOutput)
   set_param(FromWorks_blk,'OutputAfterFinalValue', ExtendOutput);
 end

 % Change Simulink Trigger block setting only if needed
 Trigger_blk = [fullblk '/Trigger'];
 TriggerType = lower(get_param(fullblk, 'TriggerType'));

 if(~isempty(findstr(TriggerType,'rising')))
   newTriggerType = 'rising';
 elseif (~isempty(findstr(TriggerType,'falling')))
   newTriggerType = 'falling';
 elseif (~isempty(findstr(TriggerType,'either')))
   newTriggerType = 'either';
 end

 if ~strcmp(get_param(Trigger_blk, 'TriggerType'), newTriggerType)
   set_param(Trigger_blk,'TriggerType', newTriggerType);
 end

 varargout = initBlock(fullblk, FromWorks_blk, ExtendOutput, varargin);

end  % End switch/case


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function argsOut = initBlock(fullblk, FromWorks_blk, ExtendOutput, argsIn)

   X      = argsIn{1};
   nSamps = argsIn{2};

   % Set Frame Status Conversion block
   setOutputFrameStatus(fullblk, X, nSamps);

   if isempty(X) | isempty(nSamps),
       % If any of the fields are empty then assign defaults
       % This let's us hit the apply button with parameters
       % yet to be defined in the MATLAB workspace.
       s.time               = [];
       s.signals.values     = 0;
       s.signals.dimensions = [1 1];

       % If you are about to run, the all params must be defined.
       if(strcmp(get_param(bdroot(gcs),'SimulationStatus'),'initializing'))
       		if isempty(X),      error('Workspace variable must not be empty'); end
       		if isempty(nSamps), error('Samples per frame must not be empty');  end
       end

   else
       if nSamps <= 0,
           error('Samples per frame must be > 0.');
       end

       % Prepare data and add buffer block if needed
       s = PrepareDataForFromWorkspace(fullblk, X, nSamps, ExtendOutput);

   end

   argsOut = {s};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  s = PrepareDataForFromWorkspace(fullblk, X, nSamps, ExtendOutput)

if ndims(X)==3
    % 3D inputs can be passed directly to the underlying
    % Simulink FromWorkspace block.
    if nSamps ~= 1,
        error('Samples per frame must be 1 for 3 dimensional inputs.');
    end

    [outRows,outCols,steps] = size(X);
    UU = X;
else
    % 1 or 2D inputs needs to be reshaped to be passed
    % to the underlying Simulink FromWorkspace block.
    % The variable to the Simulink FromWorkspace block (UU) is
    % made to be 3D, so that each frame is output as a 2D page.
    outRows = nSamps;

    [xRows, xCols] = size(X);

    % Row is a single Channel (Convenience rule)
    if(xRows==1)
        xRows = xCols;
        Xcols = 1;
        X = X(:);
    end

    switch ExtendOutput
    case 'Setting to zero'
        [UU, outCols] = reshape2D(X,nSamps);
        % Nothing extra needed for this case
    case 'Cyclic repetition'
    	% If using Cyclic Repetion, the we need the workspace  variable
    	% to have the it's number of rows to be an even multiple of the
    	% framesize.  Because the current implementation would erroneously
    	% zero pad the output and repeat the last zero padded frame.

       if(xRows > nSamps)
            R = mod(xRows, nSamps);
        else
            R = nSamps - xRows;
        end

        if( (R == 0) | nSamps == 1)
            [UU, outCols] = reshape2D(X,nSamps);
        else
            % Framebased signals that have lengths which are not
            % multiples of the framesize need the buffer block.
            % Since buffer block cannot work in multi-rate under triggered
            % subsystems, this mode is not supported.
            % Without buffer block the implementation will be very
            % inefficient (like repeating the input many times)
            % It is easier to specify an input signal with length a multiple
            % of framesize
            error('Cyclic repetition with signal length not multiple of frame size is not supported.');

        end

    case 'Holding final value'
        [UU, outCols] = reshape2D(X,nSamps);
    	% We have more work to do if HOLD FINAL VALUE is selected
    	% samples per frame is greater than one.  Fill out the remaining
    	% frame with the last value and then build an additioal frame
    	% full of final values to be repeated.

        lastRow = X(end,:); % This is the values to hold

        if(xRows > nSamps)
            % Input has one full frame and a partially full frame
            R = mod(xRows, nSamps);
            if(R > 0)
                % Fill last part of frame with last value
                pad = ones(nSamps-R,1) * lastRow;
                UU(R+1:end,:,end) = pad;
            end
            % Create a full frame of last values
            lastFrame = ones(nSamps,1) * lastRow;
            UU(:,:,end+1) = lastFrame;

        else
            % There will always be a remainder of the frame
            % that must be filled because the signal length
            % is less than the frame length in this case.
            R = nSamps-xRows;
            if(R > 0)
                % Fill last part of frame with last value
                pad = ones(R,1) * lastRow;
                UU(end-R+1:end,:) = pad;
            end
            % Create a full frame of last values
            lastFrame = ones(nSamps,1) * lastRow;
            % REPLACE with this line when fi supports 'cat'
            %UU = cat(3, UU, lastFrame);
            [mm,nn,ll] = size(UU);
            UU(1:mm,1:nn,ll+1) = lastRow(ones(nSamps,1),:);
        end
    end  % End of Switch/case

end

% Form structure input for Simulink From Workspace block
s.time               = [];
s.signals.values     = UU;
s.signals.dimensions = [outRows outCols];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [UU, nChans] = reshape2D(U,nSamps)

% if U is 1D then it is a column

% Reshape data
[m,n] = size(U);

nChans = size(U,2);

% need this line for fi objects
UU = U(1);

if (nSamps == 1)
   % Single sample per channel
   % Move  rows into 3D matrix
   UU(1,1:n,1:m) = U.';

else

   if (m==1 | n==1)
      % VECTOR input to create new 3D output:
      UU(1:nSamps,1,1:ceil(m*n/nSamps)) = buffer(U(:,1),nSamps);
   else
      % MATRIX input
      U = reshape(U.',m*n,1);       % Force into column
      V = buffer(U,nChans*nSamps);  % Buffer U

      % Reshape and put into 3D array
      nSteps = size(V,2);
      if (nSteps < nChans)   %choose the faster loop for rearranging
        for i = 1:nSteps
            UU(1:nSamps,1:nChans,i) = reshape(V(:,i),nChans,nSamps).';
        end
      else
        for i=1:nChans
            UU(1:nSamps,i,1:nSteps) = V(i:nChans:nChans*nSamps,:);
        end
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setOutputFrameStatus(fullblk, X, nSamps)

   frame_conv_blk  = [fullblk '/Frame Status'];
   frameStr        = get_param(frame_conv_blk, 'outframe');

   % Decide if data is to be output as framebased or not
   if (nSamps > 1) & (ndims(X) ~= 3),
      if ~strcmp(frameStr,'Frame-based')
         set_param(frame_conv_blk, 'outframe', 'Frame-based');
      end
   else
      if ~strcmp(frameStr,'Sample-based')
         set_param(frame_conv_blk, 'outframe', 'Sample-based');
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)

present = ~isempty(find_system(sys,'searchdepth',1,...
         'followlinks','on','lookundermasks','on','name',name));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y]=dsptrigicon(blk,trig)
% DSPTRIGICON Compute trigger icon
% BLK is the full path name of block, and TRIG is the
% trigger type, where 1=rising, 2=falling, and 3=either.

% Get block height and width in pixels:
ppos = get_param(blk,'position');
dx=ppos(3)-ppos(1);
dy=ppos(4)-ppos(2);

x0=2;
y0=floor(dy/2);

if trig==1,
   % rising
   x=[0 4 4 8 NaN 2 4 6];
   y=[-3 -3 3 3 NaN -1 1 -1];
elseif trig==2,
   % falling
   x=[0 4 4 8 NaN 2 4 6];
   y=[3 3 -3 -3 NaN 1 -1 1];
else
   % either
   x = [0 2 2 4 NaN 0 2 4 NaN 6 8 8 10 NaN 6 8 10];
   y = [-4 -4 4 4 NaN -2 2 -2 NaN 4 4 -4 -4 NaN 2 -2 2];
end
x=x+x0; y=y+y0;

return

% [EOF] dspblktsfw.m
