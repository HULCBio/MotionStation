%READ  DTREE �I�u�W�F�N�g�t�B�[���h�̓ǂݍ���
%   VARARGOUT = READ(T,VARARGIN) �́ADTREE �I�u�W�F�N�g�̃t�B�[���h����
%   1�A�܂��͕����̃v���p�e�B�l����ǂݍ��ނ��߂̍ł���ʓI�ȃV���^�b
%   �N�X�ł��B
%
%   READ �֐����Ăяo�����̕��@�́A�ȉ��̂Ƃ���ł��B
%     PropValue = READ(T,'PropName') �܂���
%     PropValue = READ(T,'PropName','PropParam')
%     ���邢�́A�O�̃V���^�b�N�X��g�ݍ��킹�܂��B
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam �̓I�v�V�����ł��B
%
%   PropName �ł͈ȉ��̍��ڂ��I���ł��܂��B
%     'sizes': PropParam = �m�[�h�̃C���f�b�N�X�x�N�g��
%
%     'data' :
%        PropParam �Ȃ����A���邢�́A
%        PropParam = 1�̖��[�m�[�h�C���f�b�N�X �Ƃ��邩�A
%        PropParam = ���[�m�[�h�C���f�b�N�X�̗�x�N�g��
%        �ŏI�I�ɁAPropValue �́A�Z���z��ɂȂ�܂��B
%
%   ���:
%     x = [0:0.1:1];
%     t = dtree(2,3,x);
%     t = nodejoin(t,[4;5]);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     stnAll = read(t,'tnsizes');
%     stnNod = read(t,'tnsizes',[4,5]);

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%
% 'an':
%    With PropParam = Vector of nodes indices.
%    NODES = READ(T,'an') returns all nodes of T.
%    NODES = READ(T,'an',NODES) returns the valid nodes of T
%    contained in the vector NODES.
%
%   �Q�l: DISP, GET, SET, WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.



%   Copyright 1995-2002 The MathWorks, Inc.
