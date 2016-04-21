function milstd = milstd_initmask(block)
% MIL_STD_INITMASK initializes the model variables in the workspace
% It stores the required values in a struct so it can be accessed by
% the different blocks in the model.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:02:05 $

%-- Get parameters from mask
milstd.rate = str2double(get_param(block,'infRate'));
rates = [4800 2400 1200 600 300 150 75]; % bps
milstd.idxRate = find(rates == milstd.rate);
milstd.interl = str2double(get_param(block,'intLength'));
interleaverLength = [0 0.6 4.8]; % seconds
milstd.idxInterl = find(interleaverLength == milstd.interl);

%-- Set Source Data Rate
set_param([bdroot(gcb) '/Bernoulli Binary Generator'],...
    'Ts',['1/' num2str(milstd.rate)]);
set_param([bdroot(gcb) '/Bernoulli Binary Generator'],...
    'sampPerFrame',[num2str(milstd.rate) '*0.2']);


%-- Init interleaver table
interlMatrixCols= [576 72; ... %2400 bps
                   288 36; ... %1200bps
                   144 18; ... %600bps
                   144 18; ... %300bps
                   144 18];  %150bps
                   
%-- Assign number of rows and columns                   
numRow = 40;
switch milstd.rate
    case 2400
        numCol = interlMatrixCols(1,(milstd.interl==0.6)+1);
    case 1200
        numCol = interlMatrixCols(2,(milstd.interl==0.6)+1);
    case {600,300,150}
        numCol = interlMatrixCols(3,(milstd.interl==0.6)+1);
end

%-- Load interleaver step
%Preallocate memory
loadPosition= zeros(numRow,numCol);
for k = 0:numRow*numCol-1,  
    loadPosition(mod(k*9,numRow)+1,floor(k/numRow)+1) = k+1;
end

%-- Fetch interleaver step
rowPos = 0;
colPos = 0;
colIni = 0;

%Preallocate memory
interTable = zeros(1,numRow*numCol);
for k = 0:numRow*numCol-1,  
    interTable(k+1) = loadPosition(rowPos+1,colPos+1);
    
    rowPos = mod(rowPos+1,numRow);
    colPos = mod(colPos-17,numCol);
    
    if(rowPos == 0)
        colPos = colIni+1;
        colIni = colPos;
    end
end

%-- Output column vector
milstd.interTable = transpose(interTable);

% Creates lookup table for D1 and D2 bits in preamble sequence
% according to MIL-STD-188-110B TABLE XV
% D1 Lookup table:
milstd.D1Table = ones(7,2);
milstd.D1Table(:,1) = [ 7 6 6 6 6 7 7]';
milstd.D1Table(:,2) = [ 0 4 4 4 4 5 5]';

% D1 Lookup table:
milstd.D2Table = ones(7,2);
milstd.D2Table(:,1) = [6 4 5 6 7 4 5]';
milstd.D2Table(:,2) = [0 4 5 6 7 4 5]';

% Channel symbol mapping for sync preamble
milstd.chSymMapping(:,1) = zeros(8,1);
milstd.chSymMapping(:,2) = [ 0 4 0 4 0 4 0 4]';
milstd.chSymMapping(:,3) = [ 0 0 4 4 0 0 4 4]';
milstd.chSymMapping(:,4) = [ 0 4 4 0 0 4 4 0]';
milstd.chSymMapping(:,5) = [ 0 0 0 0 4 4 4 4]';
milstd.chSymMapping(:,6) = [ 0 4 0 4 4 0 4 0]';
milstd.chSymMapping(:,7) = [ 0 0 4 4 4 4 0 0]';
milstd.chSymMapping(:,8) = [ 0 4 4 0 4 0 0 4]';

%-- Set Bits per channel symbol depending on the rate
switch milstd.rate
    case 2400
        milstd.bitsToSym = 3;
    case 1200
        milstd.bitsToSym = 2;
    case {600,300,150}
        milstd.bitsToSym = 1;
end

%-- Set repetition factor in error correction scheme depending
% on the rate
switch milstd.rate
    case {2400, 1200, 600}
        milstd.repFactor = 1;
        %Set encoder and decoder
        set_param([bdroot(gcb) '/FEC Encoder'],'blockChoice', ...
            'Rate 1/2 FEC Encoder');
        set_param([bdroot(gcb) '/FEC Decoder'],'blockChoice', ...
            'Rate 1/2 FEC Decoder');
    case 300
        milstd.repFactor = 2;
        %Set encoder and decoder to support repetition
        set_param([bdroot(gcb) '/FEC Encoder'],'blockChoice', ...
            'Rate 1/2 FEC Encoder with Repetition');
        set_param([bdroot(gcb) '/FEC Decoder'],'blockChoice', ...
            'Rate 1/2 FEC Decoder with Derepetition');
    case 150
        milstd.repFactor = 4;
        %Set encoder and decoder to support repetition
        set_param([bdroot(gcb) '/FEC Encoder'],'blockChoice', ...
            'Rate 1/2 FEC Encoder with Repetition');
        set_param([bdroot(gcb) '/FEC Decoder'],'blockChoice', ...
            'Rate 1/2 FEC Decoder with Derepetition');
end
%[EOF]
