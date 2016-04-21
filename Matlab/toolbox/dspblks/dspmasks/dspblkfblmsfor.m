function dspblkfblmsfor()
% DSPBLKFBLMSFOR Mask dynamic dialog function for fast blms adaptive filter
% for loop
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/11/12 21:29:44 $

blk = gcb;
load_system('adptfiltsubsys');
updateweights(blk);
updatealgo(blk);

%-----------------------------------------------------

function updateweights(blk)

weights = get_param(blk, 'weights_for');

%update weight output
cr = sprintf('\n');
load_system('dspsigattribs');
ic = ['Inherit' cr 'Complexity1'];
if (strcmp(weights, 'off'))
    %remove weights output
    if (exist_block(blk, 'Wts'))
        delete_line(blk, [ic '/1'], 'Wts/1');
        delete_line(blk, 'Algorithm/2', [ic '/1']);
        delete_line(blk, 'FromBlk4/1', [ic '/2']);
        delete_block([blk '/' ic]);
        delete_block([blk '/Wts']);
        set_param([blk, '/Algorithm'], 'weights_algo', 'off');
    end
else
    if ~(exist_block(blk, 'Wts'))
        set_param([blk, '/Algorithm'], 'weights_algo', 'on');        
        add_block('built-in/Outport', [blk, '/Wts'], ...
            'Position', [1080 213 1110 227]);
        add_block(['dspsigattribs/Inherit' cr 'Complexity'], [blk '/' ic],...
                   'Position', [925 202 970 238]);
        add_line(blk, [ic '/1'], 'Wts/1');
        add_line(blk, 'Algorithm/2', [ic '/1']);
        add_line(blk, 'FromBlk4/1', [ic '/2']);
    end
end
% -----------------------------------------------
function updatealgo(blk)
% switch between fast block lms and block lms

%first replace update block
pos = get_param([blk '/Algorithm'], 'Position');
weights = get_param(blk, 'weights_for');
if (strcmp(get_param(blk, 'algo_for'), 'Block LMS'))
    if exist_block([blk '/Algorithm'], 'FFT')  %if FFT block present then FBLMS
        delete_block([blk '/Algorithm']);
        add_block('adptfiltsubsys/BLMS Algorithm', [blk '/Algorithm'],...
                  'Position', pos,...
                  'weights_algo', weights);
    end
else    %fast block lms
    if ~exist_block([blk '/Algorithm'], 'FFT')  %if FFT block present then FBLMS
        delete_block([blk '/Algorithm']);
        add_block('adptfiltsubsys/FBLMS Algorithm', [blk '/Algorithm'],...
                  'Position',pos,...
                  'weights_algo', weights);
    end
end

% -----------------------------------------------
function present = exist_block(sys, name)
try
    present = ~isempty(get_param([sys '/' name], 'BlockType'));
catch
    present = false;
    sllastdiagnostic([]); %reset the last error
end

% -----------------------------------------------
   
% [EOF] dspblkblmsfor.m
