%DTREE   DTREE �N���X�p�̃R���X�g���N�^
%   T = DTREE(ORD,D,X) �́A���� ORD �ƁA�[�� D �̊��S�ȃf�[�^�c���[�I�u
%   �W�F�N�g���o�͂��܂��B�f�[�^�́A�c���[ T �� X �Ɋ֘A�Â����Ă���
%   ���B
%
%   T = DTREE(ORD,D,X,USERDATA) ���g���āA���[�U�f�[�^�t�B�[���h��ݒ��%   ���܂��B
%
%   [T,NB] = DTREE(...) �́AT �̖��[�m�[�h(���x��)�̐����o�͂��܂��B
%
%   T = DTREE('PropName1',PropValue1,'PropName2',PropValue2,...) �́A
%   DTREE �I�u�W�F�N�g�ō\�z�����ł���ʓI�ȃV���^�b�N�X�ł��B
%   'PropName' �ɑ΂���L���ȑI���͈ȉ��̒ʂ�ł��B
%     'order' : �c���[�̎���
%     'depth' : �c���[�̐[��
%     'data'  : �c���[�Ɋ֘A����f�[�^
%     'spsch' : �m�[�h�̕�����@
%     'ud'    : ���[�U�f�[�^�t�B�[���h
%
%   Split scheme �t�B�[���h�͘_���z��1�ɂ�� ORD �ł��B
%   �c���[�̃��[�g�� split �ŁA ORD �̎q�m�[�h�������܂��B
%   SPSCH(j) = 1 �̏ꍇ�Aj�Ԗڂ̎q�m�[�h�́Asplit �ɂȂ�܂��B
%   �e�m�[�h�ɂ����āAsplit �̓��[�g�̃m�[�h�Ɠ����v���p�e�B�������܂��B%
%   �֐� DTREE �́ADTREE �I�u�W�F�N�g���o�͂��܂��B
%   �I�u�W�F�N�g�t�B�[���h�ɂ��Ă̂��ڍׂȏ��ɂ��ẮA
%   help dtree/get ���^�C�v���Ă��������B
%
%   �Q�l: NTREE, WTBO

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.



%   Copyright 1995-2002 The MathWorks, Inc.
