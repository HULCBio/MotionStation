function varargout = dspblksfw2(action, varargin)
% DSPBLKSFW2 Signal Processing Blockset Signal From Workspace block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.26.4.4 $ $Date: 2004/04/12 23:07:14 $

if nargin==0, action = 'dynamic'; end

fullblk       = getfullname(gcb);
FromWorks_blk = [fullblk ['/From Workspace']];
ExtendOutput  = get_param(fullblk, 'OutputAfterFinalValue');

switch action
case 'init'
   % Setting Simulink FromWorkspace parameter
   if ~strcmp(get_param(FromWorks_blk, 'OutputAfterFinalValue'), ExtendOutput)
       set_param(FromWorks_blk,'OutputAfterFinalValue', ExtendOutput);
   end

   varargout = initBlock(fullblk, FromWorks_blk, ExtendOutput, varargin);
   return;
end  % end switch/case



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function argsOut = initBlock(fullblk, FromWorks_blk, ExtendOutput, argsIn)

   X      = argsIn{1};
   Ts     = argsIn{2};
   nSamps = argsIn{3};

   % Set Frame Status Conversion block
   setOutputFrameStatus(fullblk, X, nSamps);

   if isempty(X) | isempty(Ts) | isempty(nSamps),
       % If any of the fields are empty then assign defaults
       % This let's us hit the apply button with parameters
       % yet to be defined in the MATLAB workspace.
       s.time               = [];
       s.signals.values     = 0;
       s.signals.dimensions = [1 1];

       newTs  = Ts;  % Sample time of Simulink FromWorkspace block

       % If you are about to run, the all params must be defined.
       if(strcmp(get_param(bdroot(gcs),'SimulationStatus'),'initializing'))
       		if isempty(X),      error('Workspace variable must not be empty'); end
       		if isempty(Ts),     error('Sample time must not be empty');        end
       		if isempty(nSamps), error('Samples per frame must not be empty');  end
       end

   else
       if nSamps <= 0,
           error('Samples per frame must be > 0.');
       end

       if Ts <= 0 & Ts ~= -1,
           error('Sample time must be -1 or > 0.');
       end

       % Prepare data and add buffer block if needed
       s = PrepareDataForFromWorkspace(fullblk, X, nSamps, ExtendOutput);

       if(exist_block(fullblk, 'Buffer'))
           newTs = Ts;             % Don't change sample time
           if (Ts < 0)
               % Buffer exists only in cyclic repetition
               % If buffer exists then there is multi-rate and hence
               % the from workspace block can not work under triggered subssytem
               error('Sample time of -1 not supported for cyclic repetition.');
           end
       else
           if (Ts >= 0)
               newTs = Ts * nSamps;    % Update sample time for output:
           else
               newTs = Ts;             % if -1 do not multiply by frame len
           end
       end
   end

   argsOut(1:2) = {s, newTs};


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
        xCols = 1;
        X = X(:);
    end

    switch ExtendOutput
    case 'Setting to zero'
        [UU, outCols] = reshape2D(X,nSamps);
        % Nothing extra needed for this case
        remove_Buffer(fullblk);

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
            % Samplebased or signals with length that are multiple
            % of the framesize do not need the buffer block.
            remove_Buffer(fullblk);

        else
            % Framebased signals that have lengths which are not
            % multiples of the framesize need the buffer block.
            % We'll pass the variable to the FromWorkspace block
            % which will output samples one row at a time to the buffer.

            if(xRows > nSamps)
                IC = X(1:nSamps,:);    % First frame to go into IC

                UUU = [X(nSamps+1:end, :); X(1:nSamps,:)].';  % pad samples at end
                UU  = reshape(UUU, 1, xCols, []);             % make 3-D
            else
                rep = ceil(nSamps / xRows);              % Duplicate input in frame
                UU = repmat(X, rep, 1);
                IC = UU(1:nSamps,:);                     % IC equals first frame
                UUU = [UU(nSamps+1:end,:); UU(1:R,:)].'; % Circular shift data to beginning
                UU = reshape(UUU, 1, xCols, []);
            end

            outRows = 1;      % We are feeding samplebased rows to the buffer block
            outCols = xCols;  % Number of channels stays the same

            insert_Buffer(fullblk, IC);
        end

    case 'Holding final value'
        [UU, outCols] = reshape2D(X,nSamps);

    	% We have more work to do if HOLD FINAL VALUE is selected
    	% samples per frame is greater than one.  Fill out the remaining
    	% frame with the last value and then build an additioal frame
    	% full of final values to be repeated.

        remove_Buffer(fullblk);

        lastRow = X(end,:); % This is the values to hold

        if(xRows > nSamps)
            % Input has one full frame and a partially full frame
            R = mod(xRows, nSamps);
            if(R > 0)
                % Fill last part of frame with last value
				% xxx
                % pad = ones(nSamps-R,1) * lastRow;
                % UU(R+1:end,:,end) = pad;
                UU(R+1:end,:,end) = lastRow( ones(nSamps-R,1), :);
            end
            % Create a full frame of last values
			% xxx
            % lastFrame = ones(nSamps,1) * lastRow;
            % UU(:,:,end+1) = lastFrame;
            UU(:,:,end+1) = lastRow( ones(nSamps,1), :);

        else
            % There will always be a remainder of the frame
            % that must be filled because the signal length
            % is less than the frame length in this case.
            R = nSamps-xRows;
            if(R > 0)
                % Fill last part of frame with last value
				% xxx
                % pad = ones(R,1) * lastRow;
                % UU(end-R+1:end,:) = pad;
                UU(end-R+1:end,:) = lastRow(ones(R,1), :);
            end
            % Create a full frame of last values
			% xxx
            % lastFrame = ones(nSamps,1) * lastRow;
            % UU = cat(3, UU, lastFrame);

            % REPLACE with this line when fi supports 'cat'
            %UU = cat(3, UU, lastRow(ones(nSamps,1), :));
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
function insert_Buffer(fullblk, IC)
% If the Buffer block does not exist, then insert it

buffer_blk  = [fullblk '/Buffer'];

if ~exist_block(fullblk, 'Buffer')
   delete_line(fullblk,'From Workspace/1','Frame Status/1');
   load_system('dspbuff3');  % Library must be loaded to add_block
   add_block('dspbuff3/Buffer',buffer_blk);

   set_param(buffer_blk,'Position',[140    20   190    70]);

   add_line(fullblk,'From Workspace/1','Buffer/1');
   add_line(fullblk,'Buffer/1','Frame Status/1');

end

% Setting the parameters of the Buffer block
set_param(buffer_blk, 'ic', mat2str(double(IC)));
set_param(buffer_blk, 'N', mat2str(size(IC,1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remove_Buffer(fullblk)
%If the blocks exist, then remove them

if exist_block(fullblk, 'Buffer')
   delete_line(fullblk,'From Workspace/1','Buffer/1');
   delete_line(fullblk,'Buffer/1','Frame Status/1');
   delete_block([fullblk '/Buffer']);
   add_line(fullblk,'From Workspace/1','Frame Status/1')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)

present = ~isempty(find_system(sys,'searchdepth',1,...
         'followlinks','on','lookundermasks','on','name',name));


% [EOF] dspblksfw2.m
