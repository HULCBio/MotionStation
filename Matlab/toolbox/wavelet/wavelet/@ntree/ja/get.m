%GET   NTREE �I�u�W�F�N�g�t�B�[���h�̓��e���擾
%
% [FieldValue1,FieldValue2, ...] = ...
%     GET(T,'FieldName1','FieldName2', ...) �́ANTREE �I�u�W�F�N�g T ��
% �w�肳���t�B�[���h�̓��e���o�͂��܂��B
%
% [...] = GET(T) �́AT�̂��ׂẴt�B�[���h�̓��e���o�͂��܂��B
%
% 'FieldName' �Ŏg�p�ł���l�́A�ȉ��̂Ƃ���ł��B
%   'wtbo'  : �e�I�u�W�F�N�g
%   'order' : �c���[�̎���
%   'depth' : �c���[�̐[��
%   'spsch' : �m�[�h�̕�����@
%   'tn'    : ���[�m�[�h�C���f�b�N�X�����z��
%
% �܂��́AWTBO �e�I�u�W�F�N�g�̃t�B�[���h�͈ȉ��̂Ƃ���ł��B
%   'wtboInfo' : �I�u�W�F�N�g���
%   'ud'       : ���[�U�f�[�^�t�B�[���h
%
%   ���:
%     t = ntree(3,2);
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%
%   �Q�l: DISP, SET


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
