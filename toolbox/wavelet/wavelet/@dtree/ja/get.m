%GET   DTREE �I�u�W�F�N�g�̓��e���擾
%
% [FieldValue1,FieldValue2, ...] = ...
%     GET(T,'FieldName1','FieldName2', ...) �́ADTREE �I�u�W�F�N�g T ��
% �w�肳���t�B�[���h�̓��e���o�͂��܂��B
%
% [...] = GET(T) �́AT�̂��ׂẴt�B�[���h�̓��e���o�͂��܂��B
%
% 'FieldName' �Ŏg�p�ł���l�́A�ȉ��̂Ƃ���ł��B
%   'ntree' : NTREE �e�I�u�W�F�N�g
%   'allNI' : ���ׂẴm�[�h�̏��
%   'terNI' : ���[�m�[�h���
%   ------------------------------------------------------------------
%   FieldName = 'allNI' �ɑ΂��āAFieldValue �� allNI �́A�ȉ��̂悤
%   �� NBnodes�s3��̔z��ɂȂ�܂��B
%   allNI(N,:) = [ind,size(1,1),size(1,2)]
%        ind  = �m�[�h N �̃C���f�b�N�X
%        size = �m�[�h N �Ŋ֘A�Â���ꂽ�f�[�^�̃T�C�Y
%   ------------------------------------------------------------------
%   FieldName = 'terNI' �ɑ΂��āAFieldValue �� terNI �́A�ȉ��̂悤
%   ��1�s2��̃Z���z��ɂȂ�܂��B
%      terNI{1} �́A�ȉ��̂悤�� NB_TerminalNodes�s2��̔z��ɂȂ�܂��B
%      terNI{1}(N,:) �́AN�Ԗڂ̖��[�m�[�h�Ɋ֘A�Â���ꂽ�W���̃T�C
%      �Y�ł��B�m�[�h�́A������E�ɁA�ォ�牺�ɔԍ��Â����Ă��܂��B
%         ���[�g�C���f�b�N�X��0�ł��B
%      terNI{2} �́A��L�Őݒ肵�����ɍs�����ɃX�g�A���ꂽ�O�̌W�����܂�
%      �s�x�N�g���ł��B
%   ------------------------------------------------------------------
%
% �������́ANTREE �e�I�u�W�F�N�g���̃t�B�[���h
%     'wtbo'  : wtbo �e�I�u�W�F�N�g
%     'order' : �c���[�̎���
%     'depth' : �c���[�̐[��
%     'spsch' : �m�[�h�̕�����@
%     'tn'    : �c���[�̖��[�m�[�h�̔z��
%
% �������́AWTBO �e�I�u�W�F�N�g
%     'wtboInfo' : �I�u�W�F�N�g���
%     'ud'       : ���[�U�f�[�^�t�B�[���h
%
% ���:
%     t = dtree(3,2);
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%     [o,allNI,tn] = get(t,'order','allNI','tn');
%
% �Q�l: DISP, READ, SET, WRITE



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Copyright 1995-2002 The MathWorks, Inc.

