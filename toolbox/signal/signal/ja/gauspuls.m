% GAUSPULS �K�E�X�ϒ������g�p���X������
% 
% YI = GAUSPULS(T,FC,BW)�́AHz�P�ʂŕ\�������S���g��FC�Ƒш敝BW�����A
% �z��T�Ɏ��������Ԃɑ΂���P�ʐU����Gauss RF�p���X���o�͂��܂��BBW�́A
% 0���傫���Ȃ���΂Ȃ�܂���B�f�t�H���g�l�́AFC=1000 Hz�ABW=0.5 �ł��B 
%
% YI = GAUSPULS(T,FC,BW,BWR)�́A���K�������M���̃s�[�N�ɂ��āABWR dB��
% ���x���ő��肵���Ƃ�100*BW�p�[�Z���g�̑ш敝�����P�ʐU����Gauss RF�p
% ���X���o�͂��܂��B�ш敝�̊���x��BWR�́A�s�[�N�P�ʕ���U��������
% ����x�����������߁A0�����łȂ���΂Ȃ炸�A�f�t�H���g�l�́ABWR = -6 
% dB �ɂȂ�܂��B
%
% [YI,YQ] = GAUSPULS(...)�́A�����p���X�ƒ����p���X�̗������o�͂��܂��B
% [YI,YQ,YE] = GAUSPULS(...)�́ARF�M���̕�����o�͂��܂��B
%
% TC = GAUSPULS('cutoff',FC,BW,BWR,TPE)�́A�㑱�̃p���X������A�s�[�N
% ����U���ɂ��āATPE dB��艺�ɂȂ�J�b�g�I�t����TC�i0�ȏ�j���o��
% ���܂��B�ш敝�̊���x��BWR�͐�Ɠ��l�̗��R����A0�����łȂ���΂Ȃ�
% ���A�f�t�H���g�l�́ABWR = -60 dB �ɂȂ�܂��B
%
% ���͈�������ɂ��邩�ȗ�����ƁA������E���̓��͈����́A�f�t�H���g�l
% �ɒu�������܂��B
%
% ���:
%
% 1 MHz�̃T���v�����O���[�g�ŁA60%�̑ш敝������ 50 kHz��Gauss RF�p���X
% ���v���b�g���܂��B������s�[�N����40 dB��������Ƃ���Ńp���X��ł�
% �؂�܂��B
%  
%       tc = gauspuls('cutoff',50E3,.6,[],-40);
%       t  = -tc : 1E-6 : tc;
%       yi = gauspuls(t,50E3,.6); plot(t,yi)
% 
% �Q�l�F   CHIRP, SAWTOOTH, SQUARE.



%   Copyright 1988-2002 The MathWorks, Inc.
