% GETIMGFORMAT   �g���q�ƃf�o�C�X�̏����o��
% a = GETIMGFORMAT(rptcomponent,ID)�́AID�ɂ���Ďw�肳�ꂽ�C���[�W�̏�
% �����L�q����\���̂��o�͂��܂��B
%   
% �L���ȑS�Ă̏������܂ލ\���̂ɑ΂��ẮAID='ALL'�𗘗p���܂��B
% Figures, Simulink, Stateflow�ɑ΂��ėL���ȑS�Ă̏������܂ލ\���̂ɑ΂�
% �ẮA���ꂼ��ID='ALLHG','ALLSL','ALLSF'�𗘗p���܂��B
% Figures, Simulink, Stateflow�ɑ΂���f�t�H���g�̃C���[�W�̏������܂ލ\
% ���̂ɑ΂��ẮA���ꂼ��AID='AUTOHG','AUTOSL','AUTOSF'�𗘗p���܂��B
% ������AUTOXX �C���[�W�́ARPTPARENT/PREFERENCES�Őݒ肳��܂��B
%
% �e�\���̂̃t�B�[���h���ȉ��Ɏ����܂�:
% 
%     .ID      - �����̃��j�[�N�Ȏ��ʎq
%     .name    - �����̐���
%     .ext     - �����Ƌ��ɗp������t�@�C���̊g���q
%     .driver  - �v�����g�h���C�o(-dps, -dtiff��)
%     .options - �v�����g�I�v�V�����̃Z���z��
%     .isSL    - Simulink�ŗp������ꍇ��1�A�����łȂ��ꍇ��0�B
%     .isSF    - Stateflow�ŗp������ꍇ��1�A�����łȂ��ꍇ��0�B
%     .isHG    - Handle Graphics�ŗp������ꍇ��1�A�����łȂ��ꍇ��0�B
%
% �Q�l   RPTPARENT/PREFERENCES





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:51 $
%   Copyright 1997-2002 The MathWorks, Inc.
