function scanIdx=muxchanidx(object,varargin)
%MUXCHANIDX Return multiplexed scan channel index.
%
%    SCANIDX=MUXCHANIDX(OBJECT,MUXBOARD,MUXINDEX) returns the scanning index of
%    the specified multiplexed channel index, MUXINDEX.  Each MUXBOARD has up to
%    64 single-ended channels which are identified by MUXINDEX and which can range
%    from 0-31 for differential inputs and 0-63 for single-ended inputs.  The 
%    output, SCANIDX, identifies the column number of the data returned by 
%    getdata and peekdata associated with the specified multiplexed channel index.
%    MUXBOARD and MUXINDEX are vectors of equal length.
%
%    SCANIDX=MUXCHANIDX(OBJECT,ABSMUXIDX) returns the scan index of the specified
%    multiplexed channel index where ABSMUXIDX is the absolute index of the 
%    channel independent of the mux board.  For instance, the absolute index of
%    the 2rd single-ended channel on the 4th MUXBOARD (i.e. MUXBOARD 4, MUXINDEX 1) 
%    is 64*3+1.  For single-ended inputs, MUXBOARD 1 = 0-63, MUXBOARD 2 = 63-127, 
%    MUXBOARD 3 = 128-191, MUXBOARD 4 = 192-255. Please refer to the AMUX-64T 
%    User Manual for more information on what Mux channels can be added based  
%    on what channel IDs are requested and the number of Mux boards associated 
%    with the hardware.
%  
%    For example,
%       ai=analoginput('nidaq',1);
%       ai.InputType='singleended';
%       ai.NumMuxBoards=4;
%       addmuxchannel(ai);
%       scanIdx=muxchanidx(ai,4,1) % returns 14
%       scanIdx=muxchanids(ai,193) % returns 14
%
%    See also ADDMUXCHANNEL.

%   LPD
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:39:37 $

ArgChkMsg = nargchk(2,3,nargin);
if ~isempty(ArgChkMsg)
    error('daq:muxchanidx:argcheck', ArgChkMsg);
end
ArgChkMsg = nargoutchk(1,1,nargout);
if ~isempty(ArgChkMsg)
    error('daq:muxchanidx:argcheck', ArgChkMsg);
end

if ~isa(object,'analoginput') && ~strcmp(daqhwinfo(object,'AdaptorName'),'nidaq'),
   error('daq:muxchanidx:invalidadaptor', 'MUXCHANIDX only works with National Instruments'' AnalogInput objects.');
end

inputType=get(object,'InputType');
numMux=get(object,'NumMuxBoards');

if numMux==0,
    error('daq:muxchanidx:invalidnummux', 'MUXCHANIDX only works for objects associated with mux boards.');
end

if strcmp(lower(inputType),'differential'),
    maxChanIdx=32;
else
    maxChanIdx=64;
end

% Board, Index
if nargin==3,
    muxBoard=varargin{1}(:);
    muxIndex=varargin{2}(:);
    
% Abs Index
else
    absMuxIdx=varargin{1};
    muxBoard=zeros(length(absMuxIdx),1);
    muxIndex=zeros(length(absMuxIdx),1);
    
    if any(absMuxIdx < 0 | absMuxIdx > 64*numMux),
      error('daq:muxchanidx:invalidindex', 'Absolute indices must be between 0 and 64 times the number of mux boards.');
    end
    
    
    for lp=1:numMux,
        muxLoc=find(absMuxIdx >= 64*(lp-1)  & absMuxIdx <= 64*lp-1 );
        muxIndex(muxLoc)=absMuxIdx(muxLoc)-64*(lp-1);
        muxBoard(muxLoc)=lp;
    end
end

if any(muxBoard < 1 | muxBoard > 4 ),
    error('daq:muxchanidx:invalidmuxboard', 'MuxBoards must be between 1 and 4');
end

if any(muxIndex < 0 | muxIndex > maxChanIdx-1),
    error('daq:muxchanidx:invalidindex', 'MUXINDEX must be between 0 and 31 (differential) / 63 (single-ended)');
end

if length(muxBoard) ~= length(muxIndex),
    error('daq:muxchanidx:invalidindex', 'MUXBOARD and MUXINDEX must be the same length.');
end

if any(muxBoard > numMux),
    error('daq:muxchanidx:invalidmuxboard', 'MUXBOARD input is greater than NumMuxBoards');
end

% Note muxBoard is a vector
scanIdx=muxBoard*0;
actScanIdx=0;
for outLp=0:maxChanIdx/4-1,
    for muxLp=1:numMux,
        for ctLp=outLp*4:outLp*4+3,
            actScanIdx=actScanIdx+1;
            matchMuxIdx=find(muxBoard==muxLp & muxIndex == ctLp);
            scanIdx(matchMuxIdx)=actScanIdx;
        end % for ctLp
    end % for muxLp
end % for outLp