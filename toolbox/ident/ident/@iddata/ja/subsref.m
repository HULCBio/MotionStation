%IDDATA/SUBSREF  IDDATA �I�u�W�F�N�g�̃T�u�X�N���v�g��t�B�[���h�Q��
%
% IDDATA �Z�b�g����T�u�Z�b�g�𒊏o���A�v���p�e�B�l�ɃA�N�Z�X���܂��B�v��
% �p�e�B�l�ɃA�N�Z�X���邽�߂ɂ́A�C�ӂ� IDDATA �I�u�W�F�N�g DAT �ɁA��
% �̎Q�Ƒ����K�p���܂��B
%
%     DAT(SAMPLES,OUTPUTS,INPUTS,EXPERIMENTS)
%          �w�肵���f�[�^�T���v���� I/O �`�����l���A������I��
%     DAT.Fieldname
%          GET(DAT,'Fieldname') �Ɠ���
%
% ���:
%     DAT(:,:,:,5) �́A5�Ԗڂ̎����𒊏o���܂��B
%     DAT(1:50,[4,5],[1 3],5) �́A�����ԍ�5�̓��̓`�����l��1,3����o�̓`��
%     ���l��4,5�܂ł̃f�[�^�́A�͂��߂�50�T���v������Ȃ�f�[�^�Z�b�g��
%     �o���܂��B
%
% ���ׂẴf�[�^/�`�����l��/������I�����邽�߂ɂ́A�R����(:) �𗘗p���܂��B
% �`�����l����I�����Ȃ����Ƃ��w�肷�邽�߂ɂ́A[] �𗘗p���܂��B�T�u�X�N��
% �v�g OUTPUT, INPUT, EXPERIMENT �́A���̂悤�ɑΉ����閼�O�Œu�������邱
% �Ƃ��ł��܂��B
%     DAT(1:59,'Speed',{'Current','Feed'},'Day5')
%
% �����̕\�L�@�́A�C�ӂ̓K�؂ȃT�u�X�N���v�g��t�B�[���h�Q�Ƃ𑱂��ċL�q��
% �邱�Ƃ��ł��܂��B
%     DAT(1,[2 3]).InputName
%     DAT.u(1:10,[3 7])
%
% �Q�l:  IDDATA/SUBSASGN, GETEXP




%   Copyright 1986-2001 The MathWorks, Inc.
