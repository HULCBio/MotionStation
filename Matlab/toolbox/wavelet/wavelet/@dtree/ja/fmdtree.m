%FMDTREE   DTREE �I�u�W�F�N�g�̃t�B�[���h�Ǘ�
%   VARARGOUT = FMDTREE(OPT,T,VARARGIN)
%
%   DTREE �I�u�W�F�N�g�̎��s�Ɋւ��ẮADTREE �N���X�p�̃R���X�g���N�^��%   �Q�Ƃ��Ă��������B
%
% ���[�e�B���e�B:
%===========
%   T ���c���[�̏ꍇ�AI �́A���ׂẴm�[�h�����܂ލs�� V �ƃC���f�b�N
%   �X�̗���܂ރm�[�h�C���f�b�N�X C �̗�x�N�g���ł��B
%
%   V = FMDTREE('an_read',T) �́AV = GET(T,'allNI') �Ɠ����ł��B
%   V = FMDTREE('an_read',T,I)
%   V = FMDTREE('an_read',T,I,C)
%   V = FMDTREE('an_read',T,'all',C)
%
%   T = FMDTREE('an_write',T,V) �́AT = SET(T,'allNI',V) �Ɠ����ł��B
%   T = FMDTREE('an_write',T,V,'add')
%   T = FMDTREE('an_write',T,V,I)
%   T = FMDTREE('an_write',T,V,'add',C)
%   T = FMDTREE('an_write',T,V,I,C)
%
%   T = FMDTREE('an_del',T,I) �́A���ׂẴm�[�h�����B���܂��B
%   I �́A�m�[�h�C���e�b�N�����܂ރx�N�g���ł��B
%

% �����I�v�V����:
%===============================================================
% OPT = 'setinit', �����f�[�^�̐ݒ�
% OPT = 'getinit', �����f�[�^�̎擾
%---------------------------------------------------------------
% allNI - ���ׂẴm�[�h���: �z��(nbnode,3+nbinfo_by_node)
%   allNI(:,1)     = �m�[�h�C���f�b�N�X
%   allNI(:,2:3)   = �m�[�h�f�[�^�̃T�C�Y
%   allNI(:,4:end) = �N���X�Ɉˑ�
%
%   'an_del'   - ���ׂẴm�[�h���: �폜
%   'an_write' - ���ׂẴm�[�h���: ��������
%   'an_read'  - ���ׂẴm�[�h���: �ǂݍ���
%---------------------------------------------------------------
% terNI - ���[�m�[�h���: �Z���z��(1,2)
%   c{1} = �z��(nbternod,2)  <--- �T�C�Y
%   c{2} = �z��(1,:)         <--- ���
%
%   'tn_beglensiz' - ���[�m�[�h���: begin-length-size
%   'tn_write'     - ���[�m�[�h���: ��������
%   'tn_read'      - ���[�m�[�h���: �ǂݍ���
%===============================================================

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
