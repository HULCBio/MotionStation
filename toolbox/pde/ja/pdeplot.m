% PDEPLOT   PDE Toolbox �̃v���b�g�֐�
%
% H = PDEPLOT(P,E,T,P1,V1,...) �́A�ߓ_�s�� P��G�b�W�s�� E�A�O�p�`�s�� 
% T �ŋL�q����郁�b�V����Œ�`���ꂽ PDE �̉��̊֐���\�����܂��B�`��
% ����� axes �I�u�W�F�N�g�̃n���h���ԍ��́A�I�v�V�����̏o�͈��� H �ɏo
% �͂���܂��B
%
% �L���ȃv���p�e�B/�l�̑g���킹���ȉ��Ɏ����܂��B
%
%     �v���p�e�B      �l/{�f�t�H���g}
%     ----------------------------------------------------------------
%     xydata          �f�[�^ (���Ƃ��΁Au, abs(c*grad u))
%     xystyle         off | flat | {interp} |
%     contour         {off} | on
%     zdata           �f�[�^
%     zstyle          off | {continuous} | discontinuous
%     flowdata        �f�[�^
%     flowstyle       off | {arrow}
%     colormap        �J���[�}�b�v��{'cool'}�܂��̓J���[�s��
%     xygrid          {off} | on
%     gridparam       [tn; a2; a3]�O�p�`�̃C���f�b�N�X�ƕ�ԃp�����[�^��
%                     �������̂��߂�tri2grid�ɓn��
%     mesh            {off} | on
%     colorbar        off | {on}
%     title           ������{''}
%     levels          �R���^�[���x�����܂��̓��x����ݒ肵�Ă���x�N�g��
%                     {10}
%
% �Q�l   PDECONT, PDEGPLOT, PDEMESH, PDESURF



%       Copyright 1994-2001 The MathWorks, Inc.
