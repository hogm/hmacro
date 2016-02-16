/*
 * 
 * �����F
 * PL/SQL ����O���v���V�[�W���Ƃ��� SqlFmt.DLL �̊֐���
 * �Ăяo���ׂ̃T���v���X�N���v�g�B
 * 
 * �X�N���v�g���s��F
 * sqlplusw system/manager @sqlfmt
 * 
 * ���ӁF
 * create library �R�}���h�����s����ɂ� create library ���A
 * create any library �V�X�e���������K�v�ł��B
 * ���L�҂łȂ����[�U��extproc_sqlfmt �Ɋ܂܂�Ă���v���V�[�W����
 * ���s���邽�߂ɂ� extproc_sqlfmt �ɑ΂��� execute �������K�v�ł��B
 * 
 * Oracle 9i �ł͔C�ӂ̏ꏊ�� DLL ��z�u���Ďg�p�������ꍇ�A
 * listener.ora �� SID_DESC �p�����[�^�Ƃ���
 * ENVS="EXTPROC_DLLS=ANY" ��ǉ�����K�v������܂��B
 * ���̃p�����[�^���g�p���邱�Ƃ̐��ݓI�ȃ��X�N�ɂ���
 * �\������������ł��g�p���������B�ڂ����́uOracle9i Net Services�v
 * �u15�� Oracle Net Services �̊g���@�\�̎g�p�v���Q�Ƃ��ĉ������B
 */
create or replace library extproc_sqlfmt is
/*
 * ���ۂ� sqlfmt.dll ���i�[�����ꏊ�ɍ��킹�ăp�X��ύX���Ă��������B
 * �ύX��͂��� DDL �̂ݍēx���s����K�v������܂��B
 */
	'C:\borland\USER\sqlfmt\sqlfmt.dll';
/
/* �K�v�ɉ����ĉ��L�����s���� */
grant execute on extproc_sqlfmt to public ;
/* 
 * �O���v���V�[�W�����`
 */
create or replace function SQLFMT (
	StmtOrg in varchar2 /* �I���W�i���i���`�O�j�̕� */
	, IdtStr in varchar2 /* �C���f���g�Ɏg�p���镶���� */
	, MinNumComma in binary_integer  /* ���ʓ��Ɏw�肵�����ȉ��̃J���}�̏ꍇ�́A���s���Ȃ� */
	, MinPartSize in binary_integer /* ���ʓ��Ɏw�肵���o�C�g���ȓ��̕�����̏ꍇ�́A���s���Ȃ� */
	, StmtFmt out varchar2 /* ���`��̕����i�[���镶����o�b�t�@ */
) return binary_integer is
	language C
	name "_iCopyToPreparedVc2"
	library extproc_sqlfmt
	parameters (
		StmtOrg, StmtOrg LENGTH
		, IdtStr, IdtStr LENGTH
		, MinNumComma
		, MinPartSize
		, StmtFmt, StmtFmt LENGTH
	);
/
set linesize 80 pagesize 1000 long 4000;
var ret number;
/* ret = 0: ����I��  ��0: �ُ�I�� */
var stmtfmt varchar2(2000);
declare
	/*
	 * 2000 �o�C�g�𒴂��镶����ɂ͖��Ή��ł��B
	 */
	stmtorg varchar2(2000);
begin
	select text  /* ��`�⍇���̕����� */
	into stmtorg
	from all_views 
	where owner = 'SYS' 
	and view_name = 'ALL_SYNONYMS'
	;
	/* ���𐮌` */
	:ret := SQLFMT(stmtorg, chr(9), 14, 50, :stmtfmt);
end;
/
print
