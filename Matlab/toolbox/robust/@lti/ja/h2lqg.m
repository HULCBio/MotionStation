% H2LQG �A������H2����V���Z�V�X
%
% [SS_CP,SS_CL]=H2LQG(TSS_,ARETYPE) �́A���[�v�`�B�֐�Ty1u1(s)��H2�m��
% �����ŏ��ƂȂ�悤�ɓK�؂ȃ��[�v���`�d�݊֐���"�g�傳�ꂽ"�v�����gP(s)
% �ɑ΂��āAH2�œK�R���g���[�����v�Z���܂��B
%
% �v���������̓f�[�^:
%  �g��v�����g P(s): TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%
% �I�v�V��������:
%  ���J�b�`�\���o: aretype = 'eigen'�A�܂��́A'Schur' 
%                  (�f�t�H���g�́A'eigen')
%
% �o�̓f�[�^:
%  �R���g���[�� F(s)               :   SS_CP = MKSYS(acp,bcp,ccp,dcp)
%  Ty1u1(s)�̕��[�v�`�B�֐�(CLTF):   SS_CL = MKSYS(acl,bcl,ccl,dcl)
%
% �x��:  
% D11�s��0�ł��邩�A�܂��͖�肪�������ł��邩�ɒ��ӂ��Ă��������B
% D11��0�łȂ��ꍇ�ł��AH2LQG�́AD11��0�ł��邱�Ƃ����肵�ăR���g���[��
% �����߂܂��B



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
