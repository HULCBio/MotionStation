% WEEKDAY   �j���̏o��
% 
% [D,W] = WEEKDAY(T) �́A�V���A���ȓ��t�ԍ��܂��͓��t�̕�����ł��� T ��
% �^�����鐔�l�ƕ�����̌`���ŁA�j�����o�͂��܂��B����́A�Z���p��̗j��
% ���o�͂��܂��B
%
% [D, W] = WEEKDAY(T, FORM) :
% [D, W] = WEEKDAY(T, LOCALE):
% [D, W] = WEEKDAY(T, FORM, LOCALE):
% form�����́A���̂����ꂩ�ł��B
%         short   --      �ȗ��`�̗j��(�f�t�H���g)
%         long    --      ���S�ȗj��
% locale�����́A���̂����ꂩ�ł��B
%         local   --      local�����𗘗p
%         en_US   --      �f�t�H���g��US English�����𗘗p(�f�t�H���g)
%   
% �����̈����́A�������I�v�V�����ŁA���t�ԍ��̌�̔C�ӂ̏��Ԃł��܂��܂���B
%
% �j���́AEnglish locales�ɑ΂��Ă��̒l�Ɋ��蓖�Ă��Ă��܂��B
%
%                1     Sun
%                2     Mon
%                3     Tue
%                4     Wed
%                5     Thu
%                6     Fri
%                7     Sat
%
%   ���̌���locales�ɑ΂��ẮA2�Ԗڂ̏o�͈����́A����locale�ł̓����ȗj����
% �܂݂܂��B
%
% ���Ƃ��΁A[d,w] = weekday(728647) �܂��� [d,w] = weekday('19-Dec-1994')
% �́AEnglish locale�ɑ΂��Ă�d = 2 �� w = Mon ���o�͂��܂��B
% 
% �Q�l�FEOMDAY, DATENUM, DATEVEC.


%   Copyright 1984-2002 The MathWorks, Inc. 
