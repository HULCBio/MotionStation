%     << 4�u���b�N�œKH���R���g���[�� (�S�Ẳ�����) >>
%               (Safonov, Limebeer and Chiang, 1989 IJC)
%
% [SS_CP,SS_CL,HINFO,TSS_K]=HINF(TSS_P,SS_U,VERBOSE) �́A
%    "���[�v�V�t�g����"���g���āAH���R���g���[��F(S)�ƃR���g���[���̃p��
%    ���g���[�[�V����K(S)���v�Z���܂��B|| U ||_inf <=1 �ƂȂ�����U(s)
%    ��^����ƁAF(S)��K(S)�ɑ΂���U(S)���t�B�[�h�o�b�N�������\�������
%    ���B
%
% �v���������� --
%   �g��v�����g P(s): TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%
% �I�v�V�������� --
%   ����ȏk�� U(s): SS_U=MKSYS(AU,BU,CU,DU) (�f�t�H���g: U=0)
%           VERBOSE:  1�̏ꍇ�A�璷�Ȍ��ʂ̕\�� (�f�t�H���g),
%                     0�̏ꍇ�AHINF���ʂ̔�\��
%
% �o�̓f�[�^: �R���g���[�� F(s):        SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%             ���[�v Ty1u1(s):        SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%             hinfo = (hinflag,RHP_cl,lamps_max) 
%                     ("hinflag":���ݐ��̃t���O)
%             �S�Ẳ��ƂȂ�R���g���[���̃p�����g���[�[�V���� K(s):
%                    TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK2



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
