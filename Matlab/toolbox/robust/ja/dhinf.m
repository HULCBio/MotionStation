% DHINF   ���U����H������݌v(�o�ꎟ�ϊ�)
%
%     << ���U�n4-�u���b�N�œKH���R���g���[��(�S�Ẳ��̕�����) >>
%       (Bilinear Transform, Safonov, Limebeer and Chiang, 1989 IJC)
%
%   [SS_CP,SS_CL,HINFO,TSS_K]=DHINF(TSS_P,SS_U,VERBOSE)�́ASafonov,
%   Limebeer, Chiang(IJC, 1989)��"���[�v�V�t�e�B���O����"�Ƒo�ꎟ��Ԃ�
%   �g���āA���UH���R���g���[��F(z)�ƃR���g���[���̃p�����g���[�[�V����
%   K(z)���v�Z���܂��B������m������1�ȉ��̈����U(z)��^����ƁAF(z)��
%   K(z)�ɂ��āAU(z)���t�B�[�h�o�b�N���邱�Ƃō\������܂��B
%   �v����������--
%      �g��v�����gP(z) : TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%   �I�v�V��������--
%      �����U(z)       : SS_U=MKSYS(AU,BU,CU,DU) (�f�t�H���g: U=0)
%               VERBOSE :  1�̏ꍇ�A���ʂ�\�����܂�(�f�t�H���g)
%                          0�̏ꍇ�AHINF�͉����\�����܂���
%   �o�̓f�[�^: 
%       �R���g���[��F(z)        :  SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%       ���[�v�`�B�֐�Ty1y1(z):  SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%              hinfo = (hinflag,RHP_cl,lamps_max)
%       "hinflag"�́AH���̑��݂�����ASCII�̃t���O�ł��B
%       �S�Ẳ��̃R���g���[���̃p�����g���[�[�V����K(z):
%                     TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK22)
% 
%   ���̃t�@�C���́A���炩���ߓ��͈���(A,B1,B2,C1,C2,D11,D12,D21,D22)��
%   ���C�����[�N�X�y�[�X�Œ�`���Ă����ADHINF���^�C�v���邱�Ƃɂ���āA
%   �X�N���v�g�t�@�C�������Ă��g�����Ƃ��ł��܂��B���̂Ƃ��A
%   �ϐ�(ss_cp,ss_cl,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo)�́A
%   ���C�����[�N�X�y�[�X�ɏo�͂���܂��B



% Copyright 1988-2002 The MathWorks, Inc. 
