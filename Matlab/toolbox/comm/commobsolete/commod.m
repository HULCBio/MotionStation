function commod(com_fig);
%COMMOD is the computational part of COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.
 
% See also COMMGUI

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.24 $

Ycd = [];
if nargin < 1
  return;
elseif ~(com_fig > 0)
  return;
end;
handle = get(gcf, 'UserData');
if ~isempty(handle)
   h_axes = handle(1);
   h_plot = handle(2);
   textl  = handle(3:7);
   popmu  = handle(8:12);
   entr_text = handle(13:32);
   entr_valu = handle(33:52);
   exec = handle(53:67);
   load_save = handle(68:69);
   bar_color = handle(70:71);
   ex_flag = handle(72:78);
else
   error('The GUI figure is destroyed. Close the window and restart COMMGUI.');
end;

% No need right now(Mar-24,1997 with MATLAB 5.1 beta3.
%if strcmp('Run',get(exec(1),'string'))
%   set(exec(1),'String','Wait');
%   %
set(bar_color(1), 'Visible', 'off');
set(bar_color(2), 'Visible', 'on');
default_color = get(0, 'DefaultUicontrolBackgroundColor');

for i = 1 : length(entr_valu)
   if strcmp(get(entr_valu(i), 'Visible'), 'off')
      set(entr_valu(i), 'String', '');
   end;
end;

Fd = str2num(get(entr_valu(1), 'String'));
Fd = comempty(Fd, entr_valu(1), 1);
source_flag = get(popmu(1), 'Value');
if source_flag == 2
   NN = get(entr_valu(2), 'String');
   if isempty(NN)
      set(entr_valu(2), 'UserData', randint(100,1));
   end;
   NN = comempty(NN, entr_valu(2), 100);
   msgg = get(entr_valu(2), 'UserData');
   data_length = ones(1, size(msgg, 2)) * size(msgg, 1);
else
   data_length = str2num(get(entr_valu(2), 'String'));
   data_length = comempty(data_length, entr_valu(2), 100);
end;
Vaa = str2num(get(entr_valu(13), 'String'));
Vaa = comempty(Vaa, entr_valu(13), .5);

Vaa_len = length(Vaa);

MultipleNumb = str2num(get(entr_valu(3), 'String'));
MultipleNumb = comempty(MultipleNumb, entr_valu(3), 2);
MultipleNumb = comleng(MultipleNumb, Vaa, 'First Entry for channel');

if source_flag == 2
   if size(msgg, 2) < length(MultipleNumb)
      msgg(:, size(msgg,2)+1:length(MultipleNumb)) ...
         = msgg(:,1)*ones(1, length(MultipleNumb)-size(msgg,2));
   end;
end;

set(ex_flag(1:7),'Color', [0 0 .7])
for loop = 1 : Vaa_len
   set(ex_flag(7),'Visible', 'off')
   set(ex_flag(1),'Visible', 'on')
   drawnow
   if source_flag == 1
      %random Integer
      Seed = str2num(get(entr_valu(4), 'String'));
      Seed = comempty(Seed, entr_valu(4), 12345);
      if isempty(Seed)
         Seed = sum(date) * sum(handle) + loop;
      end;
      Seed = comleng(Seed, Vaa, 'Seed');
      x = randint(data_length(min(loop,length(data_length))), 1,...
         MultipleNumb(min(loop, length(MultipleNumb))));
      indx = de2bi(x, MultipleNumb(min(loop, length(MultipleNumb))))';
   elseif source_flag == 2
      x = msgg(:, loop);
      indx = de2bi(x, MultipleNumb(min(loop, length(MultipleNumb))))';
   elseif source_flag == 3
      %your own source goes here.
      error('Please put your own source code in this break segment!');
   end;
   set(bar_color(2), 'XData',[0 (loop-6/7)/Vaa_len (loop-6/7)/Vaa_len 0])
   set(ex_flag(1),'Visible', 'off')

   % error control coding
   set(ex_flag(2),'Visible', 'on')
   drawnow
   list_valu = get(popmu(2), 'Value');
    
   indx_bi = indx(:);
   if list_valu > 1
      if sum(abs(indx-floor(indx))) > 0
         error('You have to use source coding before error-control coding.');
      end;
      tmp = [...
            'Hamming ';...
            'Linear  ';...
            'Cyclic  ';...
            'BCH     ';...
            'RS      ';...
            'Convolut';...
            'My Own  '...
         ];
      mthd_cod = deblank(tmp(list_valu-1,:));
      Ncd = str2num(get(entr_valu(5), 'String'));
      if list_valu ~= 7
         Ncd = comempty(Ncd, entr_valu(5), 7);
      end;
      Mcd = str2num(get(entr_valu(6), 'String'));
      if list_valu ~= 7
         if Mcd > Ncd
            Mcd = [];
         end;
         default_v = Ncd - ceil(log(Ncd)/log(2));
         if list_valu == 6
            default_v = Ncd -2;
         end
         Mcd = comempty(Mcd, entr_valu(6), default_v);
      end;
      Xcd = get(entr_valu(7), 'String');
      if isempty(Xcd)
         if list_valu == 3
            % block
            [junk, default_v] = hammgen(ceil(log(Ncd)/log(2)));
            Xcd = comempty(Xcd, entr_valu(7), default_v);
            Ncd = 2^ceil(log(Ncd)/log(2)) - 1;
            Mcd = Ncd - ceil(log(Ncd)/log(2));
            set(entr_valu(5), 'String',num2str(Ncd));
            set(entr_valu(6), 'String',num2str(Mcd));
         elseif list_valu == 4
            % cyclic
            default_v = cyclpoly(Ncd, Mcd);
            Xcd = comempty(Xcd, entr_valu(7), default_v);
         elseif list_valu == 7
            % convolution
            Xcd = comempty(Xcd, entr_valu(7), '''fig_10_9''');
         end;
      end;
      if list_valu ~= 8
         if list_valu == 7
            if isstr(Xcd) & findstr(Xcd, '''')
               Xtmp = strtok(Xcd, '''');
               [A,B,C,D,N,K,M] = gen2abcd(Xtmp);
            else
               [A,B,C,D,N,K,M] = gen2abcd(Xcd);
            end
            Ncd = comempty(Ncd, entr_valu(5), N);        
            Mcd = comempty(Mcd, entr_valu(6), K);        
            Ycd = str2num(get(entr_valu(8), 'String'));
            Ycd = comempty(Ycd, entr_valu(8), Ncd * 2);
         end;
         if isempty(Xcd)
            code_word = encode(indx_bi, Ncd, Mcd, mthd_cod);
         else
            if findstr(Xcd, '''')
               Xcd = strtok(Xcd, '''');
            else
               if max(max((abs(Xcd)>=97) & (abs(Xcd)<=122))) | ...
                     max(max((abs(Xcd)>=65) & (abs(Xcd)<=90)))
                  Xcd = str2num(Xcd);
               end;
               if isstr(Xcd)
                  Xcd = str2num(Xcd);
               end;
            end
            code_word = encode(indx_bi, Ncd, Mcd, mthd_cod, Xcd);
         end;
      else
         % your own error-control code goes here.
         % Ncd is param1 
         % Mcd is param2
         % Xcd is param3
         % Ycd is param4
         %code_word = ???(indx, Ncd, Mcd, Xcd, Ycd);
         error('Please put your own Error-Control code in this break segment!');
      end;
   else
      code_word = indx_bi;
   end;
   set(bar_color(2), 'XData',[0 (loop-5/7)/Vaa_len (loop-5/7)/Vaa_len  0])
   set(ex_flag(2),'Visible', 'off')

  % modulation
  set(ex_flag(3),'Visible', 'on')
  drawnow
  list_valu = get(popmu(3), 'Value');
  if list_valu > 1
     Fs = str2num(get(entr_valu(9), 'String'));
     Fs = comempty(Fs, entr_valu(9), Fd*5);
     pp2 = str2num(get(entr_valu(10), 'String'));
     default1 = 16;
     default2 = 1;
     if list_valu == 5
        default1 = [1 1 -1 -1];
        default2 = [1 -1 -1 1];
     elseif list_valu == 6
        default2 = Fd;
     end;
     pp2 = comempty(pp2, entr_valu(10), default1);
     pp3 = str2num(get(entr_valu(11), 'String'));
     pp3 = comempty(pp3, entr_valu(11), default2);
     pp4 = str2num(get(entr_valu(12), 'String'));
     pp4 = comempty(pp4, entr_valu(12), 0);
     pp5 = str2num(get(entr_valu(17), 'String'));
     pp5 = comempty(pp5, entr_valu(17), 0);
     pp6 = str2num(get(entr_valu(18), 'String'));
     pp7 = str2num(get(entr_valu(19), 'String'));
     Fc = str2num(get(entr_valu(20), 'String'));
     Fc = comempty(Fc, entr_valu(20), Fs/3);
     if Fs < Fd
        disp(['Warning: Modulation sample frequency should ',...
              'be larger than digital frequuncy.']);
     end;
     if (list_valu == 9)
        % your own modulation goes here
        % modulated == ???
        error('Please put your own Modulation code in this break segment!');
     else
        if (list_valu == 2) ...
              | (list_valu == 3) ...
              | (list_valu == 6) ...
              | (list_valu == 7)
           MLP = pp2;
        elseif (list_valu == 4)
           MLP = sum(pp2);
        elseif (list_valu == 5)
           MLP = length(pp2);
        elseif (list_valu == 8)
           MLP = 2;
        end;
        bit_numb = floor(log(MLP) / log(2));
        bf_mod = vec2mat(code_word, bit_numb);
        if bit_numb > 1
           bf_mod = bi2de(bf_mod);
        end
        mthd = get(popmu(3), 'String');
        mthd = deblank(mthd(list_valu, :));
        if  get(popmu(5), 'Value') == 1
           %passband
           if isempty(pp2)
              modulated = dmod(bf_mod, Fc, Fd, [Fs, pp5], mthd);
           elseif isempty(pp3)
              modulated = dmod(bf_mod, Fc, Fd, [Fs, pp5], mthd, pp2);
           elseif isempty(pp4)
              modulated = dmod(bf_mod, Fc, Fd, [Fs, pp5], mthd, pp2, pp3);
           else
              modulated = dmod(bf_mod, Fc, Fd, [Fs, pp5], mthd, pp2, pp3, pp4);
           end;
        else
           %baseband
           if isempty(pp2)
              modulated = dmodce(bf_mod, Fd, [Fs, pp5], mthd);
           elseif isempty(pp3)
              modulated = dmodce(bf_mod, Fd, [Fs, pp5], mthd, pp2);
           elseif isempty(pp4)
              modulated = dmodce(bf_mod, Fd, [Fs, pp5], mthd, pp2, pp3);
           else
              modulated = dmodce(bf_mod, Fd, [Fs, pp5], mthd, pp2, pp3, pp4);
           end;
        end;
     end;
  else
     modulated = code_word;
  end;
  set(bar_color(2), 'XData',[0 (loop-4/7)/Vaa_len (loop-4/7)/Vaa_len  0])
  set(ex_flag(3),'Visible', 'off')

  %channel:
  % set(ex_flag(4),'Color',[1 0 0], 'Visible', 'on')
  set(ex_flag(4), 'Visible', 'on')
  drawnow
  sig_eng = sum(modulated .* conj(modulated));
    
  list_valu = get(popmu(4), 'Value');
    
  if list_valu > 1
     p51 = str2num(get(entr_valu(13), 'String'));
     p52 = str2num(get(entr_valu(14), 'String'));
     p52 = comempty(p52, entr_valu(14), 0);
     p53 = str2num(get(entr_valu(15), 'String'));
     p53 = comempty(p53, entr_valu(15), 0);
     p54 = str2num(get(entr_valu(16), 'String'));
     p54 = comempty(p54, entr_valu(16), 0);
     if list_valu == 2
        p52 = p52+loop;
        randn('seed', p52');
        if (get(popmu(3), 'Value') ~= 1) & (get(popmu(5), 'Value') == 1)
           %complex
           nois = randn(length(modulated), 2) * p51(min(loop, length(p51)));
           nois = nois(:, 1) + j*nois(:, 2);
        else
           % real
           nois = randn(length(modulated), 1) * p51(min(loop, length(p51)));
        end;
     elseif list_valu == 3
        p53 = p53 + loop;
        rand('seed', p52');
        if (get(popmu(3), 'Value') ~= 1) & (get(popmu(5), 'Value') == 1)
           %complex
           nois = rand(length(modulated), 2) * (p51(min(loop, length(p51)))...
              - p52(min(loop, length(p52))))...
              - p52(min(loop, length(p52)));
           nois = nois(:, 1) + j*nois(:, 2);
        else
           % real
           nois = randn(length(modulated), 1) * (p51(min(loop, length(p51)))...
              - p52(min(loop, length(p52))))...
              - p52(min(loop, length(p52)));
        end;
     elseif list_valu == 4
        %N/A
        if (get(popmu(3),'Value') ~= 1)
           disp('Binary noise can apply to the case without modulation only.')
           disp('No noise is added to the simulation.')
           nois = 0;
        else
           p52 = p52 + loop;
           randn('seed', p52');
           nois = rand(length(modulated), 1) < p51(min(loop, length(p51)));
        end;
     elseif list_valu == 5
        % your own noise code here
        % nois = ???
        error('Please put your own noise code in this break segment!');
     end;
     modulated = modulated(:) + nois;
     if list_valu == 4
        modulated = rem(modulated, 2);
     end;
  else
     nois = 0;
  end;
  if list_valu == 4
     if p51(min(loop, length(p51))) > 0
        snratio = 1/p51(min(loop, length(p51)));
     else
        snratio = Inf;
     end;
  else
     noi_eng = sum(nois .* conj(nois));
     if noi_eng ~= 0
        snratio = sig_eng/noi_eng;
     else
        snratio = Inf;
     end;
  end;
  set(bar_color(2), 'XData',[0 (loop-3/7)/Vaa_len (loop-3/7)/Vaa_len   0])
  set(ex_flag(4),'Visible', 'off')

  % demodualtion
  set(ex_flag(5), 'Visible', 'on')
  drawnow
  list_valu = get(popmu(3), 'Value');
  band_valu = get(popmu(5), 'Value');
  if list_valu > 1
     if loop == 1
        if isempty(pp6) & band_valu == 1
           [lpfltnum, lpfltden] = butter(5, Fc * 2 / Fs);
        else
           lpfltnum = pp6;
           lpfltden = pp7;
        end;
     end;
     if band_valu == 1
        if list_valu == 2
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], ...
              ask', pp2, lpfltnum, lpfltden);
        elseif list_valu == 3
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], ...
              'qask', pp2, lpfltnum, lpfltden);
        elseif list_valu == 4
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], ...
              'qask/cir', pp2, pp3, pp4, lpfltnum, lpfltden);
        elseif list_valu == 5
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5],...
              'qask/arb', pp2, pp3, lpfltnum, lpfltden);
        elseif list_valu == 6
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], 'fsk', pp2, pp3);
        elseif list_valu == 7
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], ...
              'psk', pp2, lpfltnum, lpfltden);
        elseif list_valu == 8
           demodulated = ddemod(modulated, Fc, Fd, [Fs, pp5], 'msk');
        elseif list_valu == 9
           % your demodualtion method goes here 
        end;
     else
        if list_valu == 2
           if isempty(pp6)
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], 'ask', pp2);
           else
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'ask', pp2, lpfltnum, lpfltden);
           end
        elseif list_valu == 3
           if isempty(pp6)
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], 'qask', pp2);
           else
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'qask', pp2, lpfltnum, lpfltden);
           end;
        elseif list_valu == 4
           if isempty(pp6)
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'qask/cir', pp2, pp3, pp4);
           else
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'qask/cir', pp2, pp3, pp4, lpfltnum, lpfltden);
           end;
        elseif list_valu == 5
           if isempty(pp6)
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'qask/arb', pp2, pp3);
           else
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'qask/arb', pp2, pp3, lpfltnum, lpfltden);
           end;
        elseif list_valu == 6
           demodulated = ddemodce(modulated, Fd, [Fs, pp5], 'fsk', pp2, pp3);
        elseif list_valu == 7
           if isempty(pp6)
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], 'psk', pp2);
           else
              demodulated = ddemodce(modulated, Fd, [Fs, pp5], ...
                 'psk', pp2, lpfltnum, lpfltden);
           end;
        elseif list_valu == 8
           demodulated = ddemodce(modulated, Fd, [Fs, pp5], 'msk');
        elseif list_valu == 9
           % your demodualtion method goes here 
           error('Please put your own Demodulation code in this break segment!');
        end;
     end;
  else
     demodulated = modulated;
     bit_numb = 1;
  end;
  demodulated = de2bi(demodulated, bit_numb)';
  demodulated = demodulated(:);
  demodulated = demodulated(1:length(code_word));
  bit_err = sum(abs(demodulated - code_word)) / length(code_word);
  set(bar_color(2), 'XData',[0 (loop-2/7)/Vaa_len (loop-2/7)/Vaa_len   0])
  set(ex_flag(5), 'Visible', 'off')

  %decode
  set(ex_flag(6), 'Visible', 'on')
  drawnow
  list_valu = get(popmu(2), 'Value');
  if list_valu > 1        
     if list_valu ~= 8
        if isempty(Xcd)
           msg = decode(demodulated, Ncd, Mcd, mthd_cod);
        elseif isempty(Ycd)
           msg = decode(demodulated, Ncd, Mcd, mthd_cod, Xcd);
        else
           msg = decode(demodulated, Ncd, Mcd, mthd_cod, Xcd, Ycd);
        end;
     else
        % your own error-control code goes here.
        %msg = ???(demodulated, Ncd, Mcd, Xcd, Ycd);
        error('Please put your own Error Control decoding code in this break segment!');
     end;
  else
     msg = demodulated;
  end;
  msg=msg(:);
  set(ex_flag(6), 'Visible', 'off')
  set(bar_color(2), 'XData',[0 (loop-1/7)/Vaa_len (loop-1/7)/Vaa_len   0])
  set(ex_flag(7), 'Visible', 'on')
  bit_err = sum(abs(msg(1:length(indx_bi)) - indx_bi)) / length(indx_bi);

  subwinchild = get(exec(8), 'Child');
  [snratio, srt] = sort([get(findobj(subwinchild,'type','line'), 'Xdata'), snratio]);
  bit_err = [get(findobj(subwinchild,'type','line'), 'Ydata'), bit_err];
  bit_err = bit_err(srt);
  set(findobj(subwinchild,'type','line'), ...
     'Xdata', snratio, ...
     'Ydata', bit_err);
  
  set(bar_color(2), 'XData',[0 (loop-0/7)/Vaa_len (loop-0/7)/Vaa_len   0])
  set(exec(3), 'Enable','on');
  drawnow;
end;

set(bar_color(2), 'Xdata', [0 0 0 0]);
set(ex_flag(1:7),'Visible', 'off');
set(entr_valu, 'ForegroundColor', [0 0 0]);

set(exec(1),'String','Run');

%else
   %do nothing right now
   %considering add several break point between each routines
   %set(exec(1),'String','Run');
%end;


%% End of COMMOD