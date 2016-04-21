function start_address_offset = aligndata(suPerVal,bitsPerSu,opt)
% This function computes for each entry's address offset that is properly
% aligned (word-aligned).
% This implementation assumes that the size of each entry is always 1
% (based on TI compiler behaviour).
% Inputs:
%  suPerVal    - storage units per value (vector)
%  bitsPerSu   - bits per storage unit
% Output:
%  start_address_offset - address offsets (vector)

% Copyright 2003 The MathWorks, Inc.

error(nargchk(2,3,nargin));

% Address offset of first stack entry
start_address_offset(1) = 0;

if bitsPerSu==16, % c54x, c55x
    
    for i=1:length(suPerVal)-1

        % start_address_offset of next data
        start_address_offset(i+1) = start_address_offset(i) + suPerVal(i);

        % Adjust start_address_offset of next data if necessary
        start_address_offset(i+1) = Bit16_AdjustNextAddrOffset(start_address_offset(i+1),suPerVal(i+1),suPerVal(i));
        
    end
    if nargin==3
        % dispOutput(start_address_offset,2,opt);
        dispOutput2(start_address_offset,2,suPerVal);
    end
    
elseif bitsPerSu==8, % c6x
    
    for i=1:length(suPerVal)-1
        
        % start_address_offset of next data
        start_address_offset(i+1) = start_address_offset(i) + suPerVal(i);

        % Adjust start_address_offset of next data if necessary
        start_address_offset(i+1) = Bit8_AdjustNextAddrOffset(start_address_offset(i+1),suPerVal(i+1),suPerVal(i));
            
    end    
    if nargin==3
        % dispOutput(start_address_offset,4,opt);
        dispOutput2(start_address_offset,4,suPerVal);
    end
    
else
    
    error('bitspersu value not supported');
    
end

%----------------------------------------------------------------------------
function addrOffset_next = Bit8_AdjustNextAddrOffset(addrOffset_next,suPerVal_next,suPerVal_curr)
% Assume: word = 32 bits
if suPerVal_curr==1 % 8-bit data
    % E.g. char -> 8-bit
    if suPerVal_next==1 % 8-bit data
            % No adjustment necessary
            % char ||  X   |      |      |      ||
            %      || char |      |  X   |      ||
            %      ||      | char |  X   |      ||
            %      ||      |      | char |      ||  X
            %      ||      |      |      | char ||  X
    elseif suPerVal_next==2 % 16-bit data
        next_start_factor = 2; % can only occur every 2 units
        % Adjustment necessary -> half-word-align
        if mod(addrOffset_next,next_start_factor)==0
            % char ||  X   |      |      |      ||
            %      ||      | char |  X   |      ||
        else
            %      || char |  x   |  X   |      ||
            %      ||      |      | char |  x   ||  X
            addrOffset_next = addrOffset_next + 1;
        end
    elseif suPerVal_next==4 % 32-bit data
        next_start_factor = 4; % can only occur every 4 units
        % Adjustment necessary -> word-align
        rem = mod(addrOffset_next,next_start_factor);
        if rem==0
			% char ||  X   |      |      |      ||
			%      ||      |      |      | char ||  X
        elseif rem==1
			%      || char |   x  |      |      ||  X
            addrOffset_next = addrOffset_next + 3;
        elseif rem==2
			%      ||      | char |  x   |      ||  X
            addrOffset_next = addrOffset_next + 2;
        elseif rem==3
			%      ||      |      | char |   x  ||  X
            addrOffset_next = addrOffset_next + 1;
        end
    elseif suPerVal_next==8 % 64-bit data
        next_start_factor = 8; % can only occur every 8fs units
        % Adjustment necessary -> word-align
        rem = mod(addrOffset_next,next_start_factor);
        if rem==0 || rem==8
			% char ||  X   |      |      |      ||      |      |      |      ||      |      |      |      ||
			%      ||      |      |      |      ||      |      |      | char ||  X   |      |      |      ||
        elseif rem==1
			%      || char |  x   |      |      ||      |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 7;
        elseif rem==2
			%      ||      | char |  x   |      ||      |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 6;
        elseif rem==3
			%      ||      |      | char |  x   ||      |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 5;
        elseif rem==4
			%      ||      |      |      | char ||   x  |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 4;
        elseif rem==5
			%      ||      |      |      |      || char |  x   |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 3;
        elseif rem==6
			%      ||      |      |      |      ||      | char |  x   |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 2;
        elseif rem==7
			%      ||      |      |      |      ||      |      | char |  x   ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 1;
        end
    else % struct/union
        next_start_factor = 4; % can only occur every 4 units
        % Adjustment necessary -> word-align
        rem = mod(addrOffset_next,next_start_factor);
        if rem==0
			% char ||  X   |      |      |      ||
			%      ||      |      |      | char ||  X
        elseif rem==1
			%      || char |   x  |      |      ||  X
            addrOffset_next = addrOffset_next + 3;
        elseif rem==2
			%      ||      | char |  x   |      ||  X
            addrOffset_next = addrOffset_next + 2;
        elseif rem==3
			%      ||      |      | char |   x  ||  X
            addrOffset_next = addrOffset_next + 1;
        end
    end
elseif suPerVal_curr==2 % 16-bit data
    
    if suPerVal_next==1 % 8-bit data
            % No adjustment necessary
            % short ||  X   |      |      |      ||
            %       ||    short    |  X   |      ||
            %       ||      |      |    short    ||  X
    elseif suPerVal_next==2 % 16-bit data
            % No adjustment necessary
            % short ||  X   |      |      |      ||
            %       ||    short    |  X   |      ||
            %       ||      |      |    short    ||  X
    elseif suPerVal_next==4 % 32-bit data
        next_start_factor = 4; % can only occur every 4 units
        % Adjustment necessary -> word-align
        if mod(addrOffset_next,next_start_factor)==0
            % short ||  X   |      |      |      ||
            %       ||      |      |    short    ||  X
        else
            %       ||    short    |  x   |      ||  X
            addrOffset_next = addrOffset_next + 2;
        end
    elseif suPerVal_next==8 % 64-bit data
        next_start_factor = 8; % can only occur every 8 units
        % Adjustment necessary -> double-word-align
        rem = mod(addrOffset_next,next_start_factor);
        if rem==0 || rem== 7
 			% short ||  X   |      |      |      ||      |      |      |      ||      |      |      |      ||
			%       ||      |      |      |      ||      |      |    short    ||  X   |      |      |      ||
        elseif rem==2
			%       ||   short     |  x   |      ||      |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 6;
        elseif rem==4
			%       ||      |      |   short     ||   x  |      |      |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 4;
        elseif rem==6
			%       ||      |      |      |      ||   short     |  x   |      ||  X   |      |      |      ||
            addrOffset_next = addrOffset_next + 2;
        end
    else % struct/union
        next_start_factor = 4; % can only occur every 4 units
        % Adjustment necessary -> word-align
        if mod(addrOffset_next,next_start_factor)==0
            % short ||  X   |      |      |      ||
            %       ||      |      |    short    ||  X
        else
            %       ||    short    |  x   |      ||  X
            addrOffset_next = addrOffset_next + 2;
        end
    end
 
elseif suPerVal_curr==4 % 32-bit data
    % Note: suPerVal=32 is already word-aligned, therefore,
    % there is no need to perform alignment on certain types.
    if suPerVal_next==1 % 8-bit data
        % No adjustment necessary
        % float ||  X   |      |      |      ||
		%       ||           float           ||  X
    elseif suPerVal_next==2 % 16-bit data
        % No adjustment necessary
        % float ||  X   |      |      |      ||
		%       ||           float           ||  X
    elseif suPerVal_next==8 % 64-bit data
        next_start_factor = 8; % can only occur every 4 units
        % Adjustment necessary -> double-word-align
        rem = mod(addrOffset_next,next_start_factor);
        if rem==0 || rem==8,
            % float ||  X   |      |      |      ||      |      |      |      ||
			%       ||      |      |      |      ||           float           || X
        elseif rem==4
			%       ||           float           ||  x   |      |      |	  || X
            addrOffset_next = addrOffset_next + 4;
        end
    else % struct/union
        % No adjustment necessary
        % float ||  X   |      |      |      ||
		%       ||           float           ||  X
    end
    
elseif suPerVal_curr==8 % 64-bit data
    % Note: suPerVal=64 is already double-word-aligned, therefore,
    % there is no need to perform alignment.

	% if suPerVal_next==1 % 8-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==2 % 16-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==4 % 32-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==8 % 64-bit data
	%     % No adjustment necessary
	% else % struct/union
	%     % No adjustment necessary
	% end
    
else % struct/union
    % Note: the suPerVal returned by the API for structs and unions
    % is always word-aligned, therefore, there is not need to perform
    % alignment.
    
	% if suPerVal_next==1 % 8-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==2 % 16-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==4 % 32-bit data
	%     % No adjustment necessary
	% elseif suPerVal_next==8 % 64-bit data
	%     % No adjustment necessary
	% else % struct/union
	%     % No adjustment necessary
	% end
    
    %% ??? what if its followed by a 64-bit data
end
        

%----------------------------------------------------------------------------------------
function addrOffset_next = Bit16_AdjustNextAddrOffset(addrOffset_next,suPerVal_next,suPerVal_curr)
% Assume: word = 32 bits
if suPerVal_curr==1 % 16-bit data
    % Compare against previous data
    if suPerVal_next==1 % 16-bit data
        % No adjustment necessary
        %  int  ||      X      |             ||
        %       ||     int     |      X      ||
        %       ||             |     int     ||  X
    elseif suPerVal_next==2 % 32-bit data
        next_start_factor = 2; % can only occur every 4 units
        rem = mod(addrOffset_next,next_start_factor);
        % Adjustment necessary -> word-align
        if rem==0 || rem==2
            %  int  ||      X      |             ||
            %       ||             |     int     ||  X
        elseif rem==1
            %       ||     int     |      x      ||  X
            addrOffset_next = addrOffset_next + 1;
        end
    else % suPerVal_next>2 % struct/union
        next_start_factor = 2; % can only occur every 4 units
        rem = mod(addrOffset_next,next_start_factor);
        % Adjustment necessary -> word-align
        if rem==0 || rem==2
            %  int  ||      X      |             ||
            %       ||             |     int     ||  X
        elseif rem==1
            %       ||     int     |      x      ||  X
            addrOffset_next = addrOffset_next + 1;
        end
    end
    
elseif suPerVal_curr==2 % 32-bit data
    % Note: Regardless of size, suPerVal==32 is already word-aligned, 
    % therefore, there is not need to perform alignment.
    
    %  float  ||  X          |             ||
    %         ||           float           ||  X

    % Compare against previous data
    if suPerVal_next==1 % 16-bit data
        % No adjustment necessary
    elseif suPerVal_next==2 % 32-bit data
        % No adjustment necessary
    else % suPerVal_next>2 % struct/union
        % No adjustment necessary
    end
    
else % suPerVal_curr>2 % struct/union
    % Note: the suPerVal returned by the API for structs and unions
    % is always word-aligned, therefore, there is not need to perform
    % alignment.
    
    %  struct  ||  X          |             ||
    %          ||           struct          ||  X

    % Compare against previous data
    if suPerVal_next==1 % 16-bit data
        % No adjustment necessary
    elseif suPerVal_next==2 % 32-bit data
        % No adjustment necessary
    else % suPerVal_next>2 % struct/union
        % No adjustment necessary
    end
    
end

%-------------------------
function dispOutput(start_address_offset,su,opt)

offset = start_address_offset;
fprintf(' ||  ');
num = 0;
offset_info = 0;
donnotContinue = 0;
for i=0:start_address_offset(end)
    if i==offset(1)
        if strcmp(opt,'x')
            fprintf('x');
        else
            num = num + 1;
            fprintf('%d',num);
        end
        offset(1) = [];
    else
        fprintf(' ');
    end
    if i>0 && mod(i+1,su)==0
        if i==start_address_offset(end)
            % fprintf('  ||\n',offset_info,offset_info+3);
            fprintf('  ||  (offsets %d-%d)\n',offset_info,offset_info+su-1);
            donnotContinue = 1;
        else
            % fprintf('  ||\n ||  ',offset_info,offset_info+3);
            fprintf('  ||  (offsets %d-%d)\n ||  ',offset_info,offset_info+su-1);
        end
        offset_info = offset_info + su;
    else
        fprintf('  |  ');
    end
end

if ~donnotContinue
	for i=start_address_offset(end)+1:start_address_offset(end)+(su-1)-mod(start_address_offset(end),su)
        fprintf(' ');
        if i>0 && mod(i+1,su)==0 
            fprintf('  ||  (offsets %d-%d)\n',offset_info,offset_info+su-1);
            % fprintf('  ||\n',offset_info,offset_info+3);
            offset_info = offset_info + su;
        else
            fprintf('  |  ');
        end
	end
end

%-------------------------
function dispOutput2(start_address_offset,su,superval)

offset = start_address_offset;
fprintf(' ||  ');
num = 0;
offset_info = 0;
donnotContinue = 0;
mark = 'o';
remainingMarks = superval(end);
for i=0:start_address_offset(end)
    if i==offset(1)
        if strcmpi(mark,'X')
            mark='o';
        else
            mark='x';
        end
        fprintf('%s',mark);
        y = 1;
        offset(1) = [];
        if i~=0
            superval(1) = [];
        end
    else
        if y<superval(1)
            fprintf('%s',mark);
            y = y + 1;
        else
            fprintf(' ');
        end
    end
    if i>0 && mod(i+1,su)==0
        if i==start_address_offset(end)
            % fprintf('  ||\n',offset_info,offset_info+3);
            fprintf('  ||  (offsets %d-%d)\n',offset_info,offset_info+su-1);
            donnotContinue = 1;
        else
            % fprintf('  ||\n ||  ',offset_info,offset_info+3);
            fprintf('  ||  (offsets %d-%d)\n ||  ',offset_info,offset_info+su-1);
        end
        offset_info = offset_info + su;
    else
        fprintf('  |  ');
    end
end

if ~donnotContinue
    j=1;
    startpt = start_address_offset(end)+1;
    endpt = start_address_offset(end)+remainingMarks-1;
    endpt = endpt + su - mod(endpt,su) - 1;
	for i=startpt:endpt
        if j<remainingMarks
            fprintf('%s',mark);
            j = j+1;
        else
            fprintf(' ');
        end
        if i>0 && mod(i+1,su)==0 
            if endpt==i
                fprintf('  ||  (offsets %d-%d)\n',offset_info,offset_info+su-1);
            else
                fprintf('  ||  (offsets %d-%d)\n ||  ',offset_info,offset_info+su-1);
            end
            offset_info = offset_info + su;
        else
            fprintf('  |  ');
        end
	end
end

% [EOF] aligndata.m