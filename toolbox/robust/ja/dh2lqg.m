% DH2LQG   ���U����H2����݌v
%
% [SS_CP,SS_CL] = DH2LQG(TSS_,ARETYPE)�́A�K�؂ȃ��[�v�V�F�[�s���O�d�݊�
% ���ɂ��g�傳�ꂽ�v�����gP(z)�ɑ΂��āA���UH2�R���g���[�����v�Z���܂��B
% ���̂Ƃ��A���[�v�`�B�֐�Ty1u1(z)��H2�m�����͍ŏ�������܂��B
%
% �v���������̓f�[�^:
%   �g��v�����gP(z) : TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%
% �I�v�V��������:
%   Riccati�\���o    : aretype = 'eigen'�܂���'Schur' 
%                                (�f�t�H���g= 'eigen')
%
% �o�̓f�[�^:
%   �R���g���[��F(z)         :     SS_CP = MKSYS(acp,bcp,ccp,dcp)
%   ���[�v�`�B�֐�Ty1u1(z) :    SS_CL = MKSYS(acl,bcl,ccl,dcl)
%
% ����: 
%    - DH2LQG�́A�����Ɉ��ʓI�ł���Ƃ��������̉��ŁA�œKH2�R���g���[��
%      ���v�Z���܂��B���Ȃ킿�A�R���g���[����D�s��́A�[���ɐ���������
%      �ŁA�������u2(i)�̌��݂̒l�́A�ϑ��M���̈ȑO�̒l{y(i-1),y(i-2),
%      y(i-3),...}�݂̂Ɉˑ����܂��B
%   
%    - �A���n��H2���_�ł́AH2��肪�K�؂ł��邽�߂ɂ̓v�����g��D11�s��
%      �[���łȂ���΂����܂��񂪁A���UH2���_�ł͂��̂悤�ȗv���͂����
%      ����B�œK���UH2�R���g���[��SS_CP�́AD11�Ɉˑ����܂���B



% Copyright 1988-2002 The MathWorks, Inc. 
