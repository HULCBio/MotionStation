% HINFOPT ���C�^���[�V�����ɂ��H���R���g���[���V���Z�V�X
%
% [GAM_OPT,SS_CP,SS_CL] = HINFOPT(TSS_,GAMIND,AUX)�A�܂��́A
% [GAM_OPT,ACP,BCP,CCP,DCP,ACL,BCL,CCL,DCL] ....
%                 = HINFOPT(A,B1,..,GAMIND,AUX) �́A�^����ꂽ�V�X�e��
% Tcl:(TSS_)�ɑ΂��āA���[�v�V�t�e�B���O�ɂ����P���ꂽ2�̃��J�b�`��
% �����ɂ��œKH�����䑥�����߂邽�߂ɁAH�����C�^���[�V���������s���܂��B
% 
% "Gam_opt"�́A���̒莮�ɑ΂��čœK��"��"�ł��B
%
%                   || gamma * Tcl(gamind,:)   ||
%                   ||                         ||     <= 1
%                   ||         Tcl(otherind,:) || inf
% �����ŁA
%       Tcl(gamind,:) �́A"��"�ɂ��d�ݕt�����ꂽ�s���܂݁A
%       Tcl(otherind,:) �́ATcl�̂��̑��̍s���܂݂܂��B
% 
%   ����           :  Tcl: TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22);
%   �I�v�V�������� :
%           gamind : ���ŃX�P�[�����O���ꂽ�o�͂̃C���f�b�N�X
%                    (�f�t�H���g: �S�Ă̏o�̓`�����l��)
%           aux    : [tol, maxgam, mingam] (�f�t�H���g: [0.01 1 0])
%                     tol    : �C�^���[�V�������I�����邽�߂̋��e�덷
%                     maxgam : �ő��"gam_opt"�̂��߂̏�������l
%                     mingam : �ŏ���"gam_opt"�̂��߂̏�������l
%   �o��: gam_opt (�œK�ȃ�)
%         H���œK�R���g���[��:        ss_cp = mksys(acp,bcp,ccp,dcp)
%         ���ŏd�ݕt�����ꂽ���[�v: ss_cl = mksys(acl,bcl,ccl,dcl)



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
