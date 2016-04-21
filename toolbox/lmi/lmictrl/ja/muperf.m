% [marg,peakf] = muperf(sys,delta,g,freqs)
% [grob,peakf] = muperf(sys,delta,0,freqs)
%
% �m�����L�E�A�܂��́A�Z�N�^�L�E�Ő��`���s�ςȕs�m���������V�X�e���̍�
% ���P�[�X��RMS���\�B
%                   ___________
%                   |         |
%              |----|  DELTA  |<---|
%              |    |_________|    |
%              |                   |
%              |    ___________    |
%              |--->|         |----|
%                   |   SYS   |
%          u  ----->|_________|----->  y
%
%
% 3�Ԗڂ̈���G�ɂ���āAMUPERF�́A���̂悤�Ɍv�Z���܂��B
%   * G > 0�Ȃ�΁Au����y�܂ł�RMS�Q�C����G��菬�����A�s�m�����̏�EM-
%     ARGIN���v�Z���܂��B���\G�́AMARGIN >= 1�ł���ꍇ�ɂ̂݃��o�X�g��
%     ���B
%   * G = 0�Ȃ�΁Au����y�܂ł̍ň��P�[�X��RMS�Q�C��GROB�ł��B���̃Q�C��
%     �́A���ݐڑ������o�X�g����ł���ꍇ�ɂ̂ݗL���ł��B
% �����̐���́A�����ʂ̏�E�Ɋ�Â��܂��B
%
% ����:
%   SYS        ���I�ȃV�X�e��(LTISYS���Q��)�B
%   DELTA      �s�m�����̋L�q(UBLOCK���Q��)�B
%   G          ���Ȃ�΁A���o�X�g�����ێ������RMS���\(�f�t�H���g = 0)�B
%   FREQS      ���g���x�N�g��(�I�v�V����)�B
%
% �o��:
%   MARGIN     �K�肳�ꂽ�ő�Q�C�� G > 0�ɑ΂��郍�o�X�g���\�]�T�B
%   GROB       ���o�X�gHinf���\�B
%   PEAKF      �ň�RMS���\�⃍�o�X�g�]�T��B��������g���B
%
% �Q�l�F     MUSTAB, MUBND, UBLOCK, UDIAG, LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
