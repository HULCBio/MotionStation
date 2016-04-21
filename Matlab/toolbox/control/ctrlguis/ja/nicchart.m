% NICCHART   Nichols���}�̃O���b�h���쐬
%
% [PHASE,GAIN,LABELS] = NICCHART(PMIN,PMAX,GMIN) �́ANichols ���}��
% �v���b�g���邽�߂̃f�[�^���쐬���܂��BPMIN �� PMAX �́A�x�P�ʂŕ\����
% �ʑ��̊Ԋu�ŁAGMIN ��dB�P�ʂŕ\�����ŏ��Q�C���ł��BNICCHART �́A
% ���̂��̂��o�͂��܂��B
%    * PHASE �� GAIN: �O���b�h�f�[�^
%    * LABELS: x �� y �̈ʒu�ƃ��x���l����Ȃ�3�s�̍s��
%
% [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX) �́A���W�� AX ���ɁANichols���}
% ���v���b�g���܂��BNICCHART �́A���݂̍��W���͈̔͂��g�p���܂��B
%
% [GRIDHANDLES,TEXTHANDLES] = NICCHART(AX,OPTIONS) �́A�t���I�ȃO���b�h
% �I�v�V�������w�肵�܂��BOPTION �́A�ȉ��̃t�B�[���h�����\���̂ł��B:
%      * PhaseUnits: 'deg' �܂��� 'rad' (�f�t�H���g = deg)
%      * Zlevel    : �����̃X�J�� (�f�t�H���g = 0)
%
% �Q�l : NICHOLS, NGRID.


%   Authors: K. Gondoly and P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:06 $
