% XBARPLOT   ���ϒl�����j�^���� X-bar �}
%
% XBARPLOT(DATA,CONF,SPECS,SIGMAEST) �́ADATA �̃O���[�v�����ꂽ������ 
% X-bar �}���쐬���܂��BDATA �̍s�́A�ݒ肵�������Ŏ��s���ꂽ�ϑ����܂��
% ���܂��B�s�́A���ԏ��ɕ��ׂ����̂ł��B
%
% CONF (optional) �́A�v���b�g����M����Ԃ̏���Ɖ������������̂ł��B
% CONF �̃f�t�H���g�l��0.9973�ł��B���̒l�́A�v���b�g�����_��99.73% ���A
% �v���Z�X���Ǘ����ɂ���ꍇ�ɁA���̊Ǘ���Ԃɓ��邱�Ƃ��Ӗ����Ă��܂��B
%
% SPECS (optional) �́A2�v�f����Ȃ�x�N�g���ŁA�����̉����Ə����ݒ�
% ������̂ł��B
%
% SIGMAEST (optional) �́ASBARPLOT ���ǂ̂悤�ɃV�O�}�𐄒肷�邩������
% ���̂ł��B���p�ł���l�́A�T�u�O���[�v�̕W���΍��̕��ς��g�� 'std'
% (�f�t�H���g)�A���ς̃T�u�O���[�v�����W���g�� 'range'�A���p���镪�U��
% ���������g�� 'variance' �ł��B
%
% OUTLIERS = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) �́ADATA �̕��ς��Ǘ��O
% �ɂȂ�s�̃C���f�b�N�X�������x�N�g�����o�͂��܂��B
%
% [OUTLIERS, H] = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) �́A�v���b�g����
% ���C���̃n���h���ԍ� H ���o�͂��܂��B


%   B.A. Jones 9/30/94
%   Modified 4/5/99 by Tom Lane
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:31 $
