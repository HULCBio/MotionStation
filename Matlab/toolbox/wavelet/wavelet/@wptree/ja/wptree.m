% WPTREE   �N���X WPTREE �p�̃R���X�g���N�^
%
% T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR) �́A�E�F�[�u���b�g
% �p�P�b�g�c���[ T �̑S�Ă��o�͂��܂��B
%
% ORDER �́A�c���[�̏��Ԃ����������ł�(���ꂼ��A�I�[�m�[�h�łȂ�
% "children" �̐�)�B2 �܂��� 4 �ɓ������Ȃ���΂Ȃ�܂���B
%
% ORDER = 2 �̏ꍇ�AT �́A�̓x�N�g��(�M��) X ���A����̃E�F�[�u���b�g 
% WNAME �Ń��x�� DEPTH �ŃE�F�[�u���b�g�p�P�b�g�����������ʂɑΉ�����
% WPTREE �I�u�W�F�N�g�ł��B
%
% ORDER = 4 �̏ꍇ�AT �́A�s��(�C���[�W) X ���A����̃E�F�[�u���b�g 
% WNAME �Ń��x�� DEPTH �ŃE�F�[�u���b�g�p�P�b�g�����������ʂɑΉ����� 
%   WPTREE �I�u�W�F�N�g�ł��B 
%
% ENT_TYPE �́A�G���g���s�[�̃^�C�v���܂ޕ�����ŁAENT_PAR �́A�G���g
% ���s�[�̌v�Z�̂��߂Ɏg����œK���p�����[�^�ł� (���ڂ������́A
% WENTROPY, WPDEC �܂��� WPDEC2 ���Q�Ƃ��Ă�������)�B
%
%   T = WPTREE(ORDER,DEPTH,X,WNAME) �́A
%   T = WPTREE(ORDER,DEPTH,X,WNAME,'shannon') �Ɠ����ł��B
%
%   T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR,USERDATA) �Ƃ��āA
%   ���[�U�f�[�^�t�B�[���h��ݒ肵�܂��B
%
%   �֐� WPTREE �́AWPTREE �I�u�W�F�N�g���o�͂��܂��B
%   �I�u�W�F�N�g�t�B�[���h�Ɋւ�����ڍׂȏ��́Ahelp wptree/get ���^
%   �C�v���Ă��������B
%
%   �Q�l: DTREE, NTREE


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Copyright 1995-2002 The MathWorks, Inc.
