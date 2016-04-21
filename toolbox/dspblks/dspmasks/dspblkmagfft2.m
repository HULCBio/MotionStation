function iconstr = dspblkmagfft2(action)
% DSPBLKMAGFFT2 Mask dynamic dialog function for
% Magnitude FFT power spectrum estimation block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:59:55 $ $Revision: 1.6 $

blk = gcb;
if nargin<1, action='dynamic'; end

% Determine "Inherit FFT length" checkbox setting
inhFftStr = get_param(blk,'fftLenInherit');


switch action
case 'init'
    % Make model changes here, in response to mask changes
    
    % Compare 'inherit' checkbox of this block
    % to the setting of the underlying zero-pad block
    %
    % If not the same, push the change through:
    zpadblk       = [blk '/Zero Pad'];
    zpadPopup     = get_param(zpadblk,'zpadAlong');
    changePending = ~(     (strcmp(inhFftStr,'on')  & strcmp(zpadPopup,'None'))    ...
                         | (strcmp(inhFftStr,'off') & strcmp(zpadPopup,'Columns')) ...
                     );
    if changePending,
        % Update the Zero Pad block underneath the top level
        if strcmp(inhFftStr, 'on'), str='None'; else str='Columns'; end
        set_param(zpadblk, 'zpadAlong', str);
    end

    magflag = get_param(blk,'mag_or_magsq');
    if strcmp(magflag, 'Magnitude squared')
      iconstr='|FFT|^2';
    else
      iconstr='|FFT|';
    end

case 'dynamic'
    % Execute dynamic dialogs
    
    % Determine if FFT length edit box is visible
    iFFTedit = 3; fftEditBoxEnabled = strcmp(inhFftStr, 'off');

    % Cache original dialog mask enables
    ena_orig = get_param(blk,'maskenables');
    ena = ena_orig;
    enaopt = {'off','on'};
    ena([iFFTedit]) = enaopt([fftEditBoxEnabled]+1);
    
    % Map true/false to off/on strings, and place into visibilities array:
    if ~isequal(ena,ena_orig),
        % Only update if a change was really made:
        set_param(blk,'maskenables',ena);
    end

case 'update'
    sqname = ['Magnitude' char(10) 'Squared'];
    sqrtname = 'Magnitude';
    fullblk  = getfullname(blk);
    % Determine "Mag or Mag Squared" setting
    magflag = get_param(blk,'mag_or_magsq');
    if strcmp(magflag, 'Magnitude squared')
      if exist_block(blk,sqrtname)
        delete_line(fullblk,'FFT/1',[sqrtname '/1'])
        delete_line(fullblk,[sqrtname '/1'], 'Out/1')
        pos = get_param([blk '/Magnitude'],'position');
        delete_block([blk '/Magnitude'])
        add_block('built-in/Math',[blk '/Magnitude Squared' char(10) ...
                    'Squared'],'position',pos, 'name', sqname,'function','magnitude^2')
        add_line(fullblk,'FFT/1',[sqname '/1'])
        add_line(fullblk,[sqname '/1'], 'Out/1')
      end
    else
      if exist_block(blk,sqname)
        delete_line(fullblk,'FFT/1',[sqname '/1'])
        delete_line(fullblk,[sqname '/1'], 'Out/1')
        pos = get_param([blk '/Magnitude Squared'],'position');
        delete_block([blk '/Magnitude Squared'])
        add_block('built-in/Abs',[blk '/Magnitude'],'position',pos,'name',sqrtname)
        add_line(fullblk,'FFT/1',[sqrtname '/1'])
        add_line(fullblk,[sqrtname '/1'], 'Out/1')
      end
    end
      
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)
    present = ~isempty(find_system(sys,'searchdepth',1,...
        'followlinks','on','lookundermasks','on','name',name));


% [EOF] dspblkmagfft2.m
