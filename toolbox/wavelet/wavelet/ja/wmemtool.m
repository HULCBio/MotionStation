% WMEMTOOL �@�������c�[���̊Ǘ��R�}���h
%
% ��ʃo�b�t�@�I�v�V����
% -----------------------
% 'handle' �A'create' �A'close'�A'empty' ,
% 'put'�A'get'�A'del'�A'find'.
%  
% HDL = WMEMTOOL('handle')
% HDL = WMEMTOOL('create')
% WMEMTOOL('close')
% WMEMTOOL('empty')
% WMEMTOOL('put',NAME,VAL)�A�܂��́Awmemtool('put',NAME,VAL,STRINFO) �́A�o�b�t
% �@�����o����Ȃ��ꍇ�ɁA�o�b�t�@�����o���܂��B
%
% VAL = WMEMTOOL('get',NAME,STRINFO)�́A"NAME" �Ŏw�肳�ꂽ�ϐ������o����Ȃ���
% ���A[]���o�͂��܂��B
%
% WMEMTOOL('del',NAME,VAL)�A�܂��́AWMEMTOOL('del',NAME,VAL,STRINFO)
%
% REP = WMEMTOOL('find') �́A�o�b�t�@�����݂���ꍇ1���A���̏ꍇ��0���o�͂��܂��B
%
%  FIGURE �I�v�V�����ɂ�����o�b�t�@
% ----------------------------
% T = WMEMTOOL('ini',FIG,BLOCNAME,NBVAL)
% T = WMEMTOOL('hmb',FIG,BLOCNAME)
% T �́AMemBloc ���܂ރe�L�X�g�̃n���h���ł��B
%
% WMEMTOOL('wmb',FIG,BLOCNAME,IND1,V1,...,IND12,V12),
% [V1,..V12] = WMEMTOOL('rmb',FIG,BLOCNAME,IND1,...,IND12),
% Vj = MemBloc �� j �Ԗڂ̒l 
% INDj = MemBloc �� j �Ԗڂ̃C���f�b�N�X
%
% WMEMTOOL('dmb',FIG,BLOCNAME) �́A�w�肳�ꂽ MemBloc ���폜���܂��B
% 



%   Copyright 1995-2002 The MathWorks, Inc.
