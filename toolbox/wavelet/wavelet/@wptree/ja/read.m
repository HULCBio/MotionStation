%READ   WPTREE �I�u�W�F�N�g�t�B�[���h�̒l��ǂݍ���
%   VARARGOUT = READ(T,VARARGIN) �́AWPTREE �I�u�W�F�N�g�̃t�B�[���h����%   1�A�܂��͕����̃v���p�e�B�l����ǂݍ��ނ��߂̍ł���ʓI�ȃV���^�b
%   �N�X�ł��B
%
%   READ �֐����Ăяo�����̕��@�́A�ȉ��̂Ƃ���ł��B
%     PropValue = READ(T,'PropName') �܂��́A
%     PropValue = READ(T,'PropName','PropParam')
%     ���邢�́A�O�̃V���^�b�N�X��g�ݍ��킹�܂��B
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam �̓I�v�V�����ł��B
%
%   PropName �ł͈ȉ��̍��ڂ��I���ł��܂��B
%     'ent', 'ento', 'sizes' (WPTREE ���Q��):
%        PropParam ���Ȃ��ꍇ�APropValue �́A��ʃm�[�h�̃C���f�b�N�X��
%        ���̃c���[�m�[�h�̃G���g���s�[(�܂��́A�œK�ȃG���g���s�[���T�C%        �Y)���A�m�[�h�C���f�b�N�X�̃x�N�g���ł��� PropParam ���܂݂�
%        ���B
%
%     'cfs': PropParam = 1�̖��[�m�[�h�C���f�b�N�X�Ƃ����ꍇ
%        cfs = READ(T,'cfs',NODE) �́A
%        cfs = READ(T,'data',NODE) �Ɠ����ŁA���[�m�[�h NODE �̌W�����o
%        �͂��܂��B
%
%     'entName', 'entPar', 'wavName' (WPTREE ���Q��), 'allcfs':
%        PropParam ���Ȃ��ꍇ
%        cfs = READ(T,'allcfs') �́Acfs = READ(T,'data') �Ɠ����ł��B
%        PropValue �́A�c���[�m�[�h�̏�ʂ̃m�[�h�C���f�b�N�X�����Ő݌v
%        ���ꂽ�����܂݂܂��B
%     
%     'wfilters' (WFILTERS ���Q��):
%        PropParam ���Ȃ����A�܂��� PropParam = 'd', 'r', 'l', 'h' �Ƃ�
%        ��܂��B
%
%     'data' :
%        PropParam �Ȃ����A���邢�́A
%        PropParam = 1�̖��[�m�[�h�C���f�b�N�X �Ƃ��邩�A
%        PropParam = ���[�m�[�h�C���f�b�N�X�̗�x�N�g��
%        �ŏI�I�ɁAPropValue �́A�Z���z��ɂȂ�܂��B
%        PropParam ���Ȃ��ꍇ�APropValue �́A��ʃm�[�h�C���f�b�N�X�̎� %        ���̃c���[�m�[�h�̌W�����܂݂܂��B
%
%   ���:
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);  
%     eAll = read(t,'ent');
%     eNod = read(t,'ent',[0,4,5]); 
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     [lo_D,hi_D,lo_R,hi_R] = read(t,'wfilters');
%     [lo_D,lo_R,hi_D,hi_R] = read(t,'wfilters','l','wfilters','h');
%     [ent,ento,cfs4,cfs5]  = read(t,'ent','ento','cfs',4,'cfs',5);
%
%   �Q�l: DISP, GET, SET, WPTREE, WRITE

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%    Examples:
%      stnAll = read(t,'tnsizes');
%      stnNod = read(t,'tnsizes',[1,2]);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
