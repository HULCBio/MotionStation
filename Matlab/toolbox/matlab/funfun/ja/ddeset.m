% DDESET  DDE OPTIONS�\���̂̍쐬�ƏC��.
%
% OPTIONS = DDESET('NAME1',VALUE1,'NAME2',VALUE2,...) �́A�w�肵��
% �v���p�e�B���w�肵���l�����ϕ��I�v�V�����\����OPTIONS���쐬���܂��B
% �w�肳��Ă��Ȃ��v���p�e�B�́A�f�t�H���g�l���g���܂��B�ݒ肷��v���p�e�B
% ���́A�v���p�e�B�������ʂł���͈͂ō\���܂���B�܂��A�啶���A������
% �̋�ʂ͂���܂���B 
%   
% OPTIONS = DDESET(OLDOPTS,'NAME1',VALUE1,...) �́A���ɐݒ肳���
% ����I�v�V�����\����OLDOPTS��ύX���܂��B
%   
% OPTIONS = DDESET(OLDOPTS,NEWOPTS) �́A���ɐݒ肳��Ă���I�v
% �V�����\����OLDOPTS�ƁA�V�K�I�v�V�����\����NEWOPTS��g�����܂��B
% �V�K�v���p�e�B�́A�Ή�����Â��v���p�e�B��ύX���܂��B
%   
% DDESET ���g�ł́A���ׂẴv���p�e�B���Ǝ�蓾��l��\�����܂��B
%   
% DDESET�v���p�e�B
%   
% RelTol - ���΋��e�덷 [ ���̃X�J�� {1e-3} ]
%    ���̃X�J���ʂ́A���ׂẲ��̃x�N�g���ɓK�p����A�f�t�H���g��
%    1e-3 (0.1% �̐��x)�ł��B�e�ϕ��X�e�b�v�ł̐���덷�́A
%    e(i) <= max(RelTol*abs(y(i)),AbsTol(i))�𖞑����܂��B
%
% AbsTol - ��΋��e�덷 [ ���̃X�J���܂��̓x�N�g�� {1e-6} ]
%    �X�J�����e�l�́A���̃x�N�g���̂��ׂĂ̗v�f�ɓK�p����܂��B
%    ���e�l�x�N�g���̗v�f�́A���̃x�N�g���̑Ή�����v�f�ɓK�p����܂��B
%    AbsTol �̃f�t�H���g�́A1e-6�ł��B
%
% NormControl - ���̃m�����̌덷�̐��� [ on | {off} ]
%    norm(e) <= max(RelTol*norm(y),AbsTol)�ł���e�ϕ��X�e�b�v�ł̌덷
%    ���\���o�����䂷�邽�߂ɁA���̃v���p�e�B��'on' �ɐݒ肵�܂��B
%    �f�t�H���g�ł́A�\���o�́A��茵���ȗv�f�P�ʂ̌덷����𗘗p���܂��B
%
% Events - �C�x���g�̌��o [ �֐� ]
%    �C�x���g�����o���邽�߂ɁA���̃v���p�e�B�̓C�x���g�֐��ɐݒ肵�܂��B
%   
% InitialStep - ��������鏉���X�e�b�v�T�C�Y [ ���̃X�J�� ]
%    �\���o�́A���̒l���ŏ��Ɏ����܂��B�f�t�H���g�ł́A�\���o�͏���
%    �X�e�b�v�T�C�Y�������I�Ɍ��肵�܂��B
%
% MaxStep - �X�e�b�v�T�C�Y�̏�� [ ���̃X�J�� ]
%    MaxStep �̃f�t�H���g�́A���tspan��1/10�ł��B
%   
% OutputFcn - �ݒ�\�ȏo�͊֐� [ �֐� ]
%   ���̏o�͊֐��́A�e���ԃX�e�b�v�̌�Ƀ\���o�ɂ���ČĂяo����܂��B
%   �\���o���o�͈����Ȃ��ŌĂяo�����Ƃ��́AOutputFcn �̃f�t�H���g��
%   �֐�odeplot�ł��B�����łȂ��ꍇ�́AOutputFcn�̃f�t�H���g�� [] �ł��B
%   
% OutputSel - �o�͑I���C���f�b�N�X [ �����̃x�N�g�� ]
%   ���̃C���f�b�N�X�̃x�N�g���́A���̃x�N�g���̂ǂ̗v�f��OutputFcn��
%   �n����邩���w�肵�܂��BOutputSel�̃f�t�H���g�͑S�v�f�ł��B
%   
% Stats - �v�Z�ʂ̕\��  [ on | {off} ]
%   
% InitialY - ���̏����l [ �x�N�g�� ]
%   �f�t�H���g�ł́A���̏����l�́A�����̓_��HISTORY�ɂ���ďo�͂����l
%   �ł��BInitialY�v���p�e�B�̒l�ɂ���Ă͈قȂ鏉���l���^������ꍇ
%   ������܂��B
%
% Jumps - ���̕s�A���� [ �x�N�g�� ]
%   history�܂��͉����᎟�̔��W���ŃW�����v�ɂ��s�A�������_ t�B
%   
% �Q�l �F DDEGET, DDE23.


%   Copyright 1984-2003 The MathWorks, Inc. 
