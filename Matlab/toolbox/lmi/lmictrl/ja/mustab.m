% [margin,peakf,fs,ds,gs] = mustab(sys,delta,freqs)
%
% �m�����L�E�A�܂��́A�Z�N�^�L�E�Ő��`���s�ςȕs�m���������V�X�e���̃�
% �o�X�g����]�TMARGIN�𐄒肵�܂��B
%                   ___________
%                   |         |
%              +----|  DELTA  |<---+
%              |    |_________|    |
%              |                   |
%              |    ___________    |
%              +--->|         |----+
%                   |   SYS   |
%          u  ----->|_________|----->  y
%
%
% MARGIN >= 1�Ȃ�΁A���ݐڑ��̓��o�X�g����ł��B
%
% MARGIN�̋t���́A�����ʂ̏�E�ł��B
%
% ����:
%  SYS         ���I�V�X�e��(LTISYS���Q��)�B
%  DELTA       �s�m�����̍\��(UBLOCK���Q��)�B
%  FREQS       �I�v�V�������͂ł�����g���_�x�N�g���B
%
% �o��:
%  MARGIN      ���o�X�g����]�T�B
%  PEAKF       �]�T�������Ƃ��������Ȃ���g���B
%  FS,DS,GS    �e�X�g���ꂽ���g��FS�ł�D,G�X�P�[�����O�B
%              ���g��FS(i)�ł̃X�P�[�����ODi, Gi�́A���̎��ŗ^������
%              ���B
% 
%                  Di = getdg(DS,i);    Gi = getdg(GS,i);
%
% �Q�l�F      MUBND, MUPERF, GETDG, UBLOCK, UDIAG, UINFO.



% Copyright 1995-2002 The MathWorks, Inc. 
