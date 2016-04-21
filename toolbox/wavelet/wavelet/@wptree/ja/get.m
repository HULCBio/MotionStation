%GET   WPTREE �I�u�W�F�N�g�t�B�[���h�̓��e���擾
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) �́AWPTREE �I�u�W�F�N�g T %   �Ŏw�肳���t�B�[���h�̓��e���o�͂��܂��B
%   �I�u�W�F�N�g�A�܂��͍\���̂̃t�B�[���h�ɑ΂��āA�T�u�t�B�[���h�̓��e%   ���擾���邱�Ƃ��ł��܂� (�ȉ��̗������Q�Ƃ�������)�B
%
%   [...] = GET(T) �́AT�̂��ׂẴt�B�[���h�̓��e���o�͂��܂��B
%
%   'FieldName' �Ŏg�p�ł���l�́A�ȉ��̂Ƃ���ł��B
%     'dtree'   : DTREE �e�I�u�W�F�N�g
%     'wavInfo' : �\���� (�E�F�[�u���b�g���)
%        'wavName' - �E�F�[�u���b�g��
%        'Lo_D'    - �������[�p�X�t�B���^
%        'Hi_D'    - �����n�C�p�X�t�B���^
%        'Lo_R'    - �č\�����[�p�X�t�B���^
%        'Hi_R'    - �č\���n�C�p�X�t�B���^
%
%     'entInfo' : �\���� (�G���g���s�[���)
%        'entName' - �G���g���s�[��
%        'entPar'  - �G���g���s�[�p�����[�^
%
%   �܂��́ADTREE �e�I�u�W�F�N�g�̃t�B�[���h
%     'ntree' : NTREE �e�I�u�W�F�N�g
%     'allNI' : ���ׂẴm�[�h���
%     'terNI' : ���[�m�[�h���
%     ------------------------------------------------------------------%      FieldName = 'allNI' �ɑ΂��āAFieldValue �� allNI �́A�ȉ��̂悤
%      �� NBnodes�s5��̔z��ɂȂ�܂��B
%      allNI(N,:) = [ind,size(1,1),size(1,2),ent,ento]
%          ind  = �m�[�h N �̃C���f�b�N�X
%          size = �m�[�h N �Ŋ֘A�Â���ꂽ�f�[�^�̃T�C�Y
%          ent  = �m�[�h N �̃G���g���s�[
%          ento = �œK�ȃG���g���s�[�m�[�h N
%     ------------------------------------------------------------------%      FieldName = 'terNI' �ɑ΂��āAFieldValue �� terNI �́A�ȉ��̂悤
%      ��1�s2��̃Z���z��ɂȂ�܂��B
%      terNI{1} �́A�ȉ��̂悤�� NB_TerminalNodes�s2��̔z��ɂȂ�܂��B%         terNI{1}(N,:) �́AN�Ԗڂ̖��[�m�[�h�Ɋ֘A�Â���ꂽ�W���̃T�C
%         �Y�ł��B�m�[�h�́A������E�ɁA�ォ�牺�ɔԍ��Â����Ă��܂��B%         ���[�g�C���f�b�N�X��0�ł��B
%      terNI{2} �́A��L�Őݒ肵�����ɍs�����ɃX�g�A���ꂽ�O�̌W�����܂�%      �s�x�N�g���ł��B
%     ------------------------------------------------------------------%
%   �������́ANTREE �e�I�u�W�F�N�g���̃t�B�[���h
%     'wtbo'  : wtbo �e�I�u�W�F�N�g
%     'order' : �c���[�̎���
%     'depth' : �c���[�̐[��
%     'spsch' : �m�[�h�̕�����@
%     'tn'    : �c���[�̖��[�m�[�h�̔z��
%
%   �������́AWTBO �e�I�u�W�F�N�g
%     'wtboInfo' : �I�u�W�F�N�g���
%     'ud'       : ���[�U�f�[�^�t�B�[���h
%
%   ���:
%     x = rand(1,1000);
%     t = wpdec(x,2,'db2');
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%     [o,allNI,tn] = get(t,'order','allNI','tn');
%     [o,wavInfo,allNI,tn] = get(t,'order','wavInfo','allNI','tn');
%     [o,tn,Lo_D,EntName] = get(t,'order','tn','Lo_D','EntName');
%     [wo,nt,dt] = get(t,'wtbo','ntree','dtree');
%
%   �Q�l: DISP, READ, SET, WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
