% SUBSREF �́AIDMODEL ���f���p��Subsref ���\�b�h�ł��B
% ���̃��t�@�����X���Z�́A�C�ӂ� IDMODEL �I�u�W�F�N�g MOD �ɓK�p�����
% ���B
% MOD(Outputs,Inputs) �́AI/O �`�����l���̃T�u�Z�b�g��I�����܂��B
% MOD.Fieldname �́AGET(MOD,'Filedname') �Ɠ����ł��B
% �����̕\���́AMOD(1,[2 3]).inputname �� MOD.cov(1:3,1:3) �̂悤�ȃT�u
% �X�N���v�g�Q�ƂƂ��Đ������L�@�𗘗p�ł��܂��B
%
% �`�����l���Q�Ƃ́A�`�����l������ԍ��Őݒ肳��܂��B
%     MOD('velocity',{'power','temperature'})
% �P�o�̓V�X�e���ɑ΂��āAMOD(ku) �́A���̓`�����l�� ku ��I�����A����A
% �P���̓V�X�e���ɑ΂��āAMOD(ky) �́A�o�̓`�����l�� ky ��I�����܂��B
% 
% MOD('measured') �́A������̓`�����l����I�����āA�m�C�Y���͂𖳎�����
% ���B
% MOD('noise') �́AMOD �ւ̕t���I�m�C�Y����(������̓`�����l���ł͂Ȃ�)��
% ���n��L�q��^���܂��B
%     
% ����`�����l���ƃm�C�Y�`�����l�������ɁA��舵�����߂ɂ́A�͂��߂ɁA
% NOISECNV���g�p���ăm�C�Y�`�����l����ϊ����Ă��������B



%   Copyright 1986-2001 The MathWorks, Inc.
