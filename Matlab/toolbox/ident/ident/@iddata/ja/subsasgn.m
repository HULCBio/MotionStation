% SUBSASGN �́AIDDATA �I�u�W�F�N�g�ɑ΂���T�u�X�N���v�g�ɂ��ݒ�
%
% ���̑�����Z���A�C�ӂ�IDDATA �Z�b�g DAT �ɓK�p�ł��܂��B
% DAT(Samples,Outputs,Inputs,Experiments)=RHS �́A�f�[�^�`�����l���̃T�u
% �Z�b�g���đ�����܂��B
%     DAT(:,3) = DAT(:,3,:) �̂悤�ɁA':'�𗘗p���Ĉ������ȗ��ł��܂��B
%     DAT.Fieldname=RHS �́ASET(DAT,'Fieldname',RHS) �Ɠ����ł��B
% ���ӂ̕\���́ADAT(:,:,3).inputname='u'�A�܂��́ADAT(11:20,2).y=[1:10]' 
% �̂悤�ɁA�T�u�X�N���v�g�Q�ƂƂ��Đ������L�@�𗘗p�ł��܂��B
%
% �Â������ɐV�����������}�[�W����ɂ́ADAT{:,:,:,expno} = DAT2; �Ŏ��s��
% �܂��B
% 
% �T���v���A�`�����l���A�����́A�w�肵���C���f�b�N�X�����݂���f�[�^�ɑ�
% ������ꍇ�A��������������A���݂��Ȃ��ꍇ�A�V�����T���v��/�`�����l��/
% �������������܂��B
%
% ���� OUTPUT, INPUT, EXPERIMENT �̔ԍ��́A ���̂悤�ɁA�Ή����閼�O��
% ��p���邱�Ƃ��ł��܂��B
%
%     DAT(1:59,'Speed',{'Current','Feed'},'Day5')
%
% �V���^�b�N�X
% 
%   DAT(Samp,Outp,Inp,Exp) = []
% 
% �́A���ʂȈӖ��������܂��B�w�肳�ꂽ�����Ɋւ���T���v���Əo�́A���̓`
% �����l�����폜����܂��B�܂�A�w�肵���A�C�e���Ɋ��S�Ɉ�v����f�[�^
% ���I������܂��B�����ŁA�������ȗ�����Ƌ�s��Ƃ��Ď�舵���A�����
% �̃`�����l���Ɋւ��Ă͉e����^���܂���B����ɁA���̏ꍇ�ASamp = ':'��
% ��s��Ƃ��Ď�舵���܂��B��������Ɋւ��āA���ׂĂ̓��̓`�����l���A
% �܂��́A���ׂĂ̏o�̓`�����l�����폜�������ꍇ�Adat([],[],[1:Nu],2) ��
% �悤�ɍ폜����`�����l���𖾎��I�ɋL�q����K�v������܂��B
% 
% �Q�l:  IDDATA/SET, IDDATA/SUBSREF, IDDATA/MERGE



%   Copyright 1986-2001 The MathWorks, Inc.
