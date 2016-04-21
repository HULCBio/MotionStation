%% Reading Arbitrary Format Text Files with textscan
% This example shows how to read an arbitrary format text file with
% |textscan|. This function is similar to |textread|, however it also
% allows you to read the file one block at a time, and each block can have
% a different format. The information in the text file test80211.txt is
% the result from a wireless network communication quality test. Each block
% is a different environment (e.g., mobile, indoor, outdoor). The numerical
% results show the data error rate over a range of noise levels for a
% number of independent tests.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2004/03/22 23:54:42 $

%% File format
% After 4 lines of introduction, this particular file is made up of a
% number blocks of data, each with the following format:
%
% * Two headerlines of description
% * A parameter m
% * A p x m table of data
%
% All the information is read into cell arrays, allowing the storage 
% of different size blocks.

%% Open the text file for reading
fid = fopen('test80211.txt','r');             % Open text file

%% Read introduction lines
InputText=textscan(fid,'%s',4,'delimiter','\n'); % Read strings delimited by a carriage return
Intro=InputText{1};
disp(Intro);

%% Read each block
% For each block, we read a header, a table name, column headers for the
% data, then the data itself.

Block = 1;   % Initialize block index
while (~feof(fid)) % For each block...
    
    disp(['Block: ' num2str(Block)]);                % Display block number
    InputText=textscan(fid,'%s',2,'delimiter','\n'); % Read header line
    HeaderLines{Block,1}=InputText{1};          
    disp(HeaderLines{Block});
 
    InputText=textscan(fid,'Num SNR=%f'); % Read parameter value
    NumCols=InputText{1};            

    FormatString=repmat('%f',1,NumCols);  % Create format string based on parameter
    InputText=textscan(fid,FormatString,'delimiter',','); % Read data block
    
    Data{Block,1}=cell2mat(InputText); % Convert to numerical array from cell
    [NumRows,NumCols]=size(Data{Block});  % Size of table
    disp(cellstr(['Table data size: ' num2str(NumRows) ' x ' num2str(NumCols)]));
    disp(' '); % New line
    
    eob=textscan(fid,'%s',1,'delimiter','\n');  % Read and discard EOB marker ('EOF' in this case)
    Block = Block+1;                            % Increment block index
end

%% Close the text file
fclose(fid);   

%% How many blocks
% How many blocks were there?
NrOfBlocks = Block-1

%% Look at data
% Let's take a look at the numerical data in one of the blocks.
Block=9;

% Headers and Data
disp(HeaderLines{Block});
disp(['SNR' sprintf('        %d',Data{Block,1}(1,2:end))])

format short e % Use exponential format

disp(' ');
disp(Data{Block,1}(2:end,2:end));
