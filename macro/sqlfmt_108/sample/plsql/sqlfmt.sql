/*
 * 
 * 説明：
 * PL/SQL から外部プロシージャとして SqlFmt.DLL の関数を
 * 呼び出す為のサンプルスクリプト。
 * 
 * スクリプト実行例：
 * sqlplusw system/manager @sqlfmt
 * 
 * 注意：
 * create library コマンドを実行するには create library か、
 * create any library システム権限が必要です。
 * 所有者でないユーザがextproc_sqlfmt に含まれているプロシージャを
 * 実行するためには extproc_sqlfmt に対する execute 権限が必要です。
 * 
 * Oracle 9i では任意の場所へ DLL を配置して使用したい場合、
 * listener.ora の SID_DESC パラメータとして
 * ENVS="EXTPROC_DLLS=ANY" を追加する必要があります。
 * このパラメータを使用することの潜在的なリスクについて
 * 十分理解した上でご使用ください。詳しくは「Oracle9i Net Services」
 * 「15章 Oracle Net Services の拡張機能の使用」を参照して下さい。
 */
create or replace library extproc_sqlfmt is
/*
 * 実際に sqlfmt.dll を格納した場所に合わせてパスを変更してください。
 * 変更後はこの DDL のみ再度実行する必要があります。
 */
	'C:\borland\USER\sqlfmt\sqlfmt.dll';
/
/* 必要に応じて下記を実行する */
grant execute on extproc_sqlfmt to public ;
/* 
 * 外部プロシージャを定義
 */
create or replace function SQLFMT (
	StmtOrg in varchar2 /* オリジナル（整形前）の文 */
	, IdtStr in varchar2 /* インデントに使用する文字列 */
	, MinNumComma in binary_integer  /* 括弧内に指定した数以下のカンマの場合は、改行しない */
	, MinPartSize in binary_integer /* 括弧内に指定したバイト数以内の文字列の場合は、改行しない */
	, StmtFmt out varchar2 /* 整形後の文を格納する文字列バッファ */
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
/* ret = 0: 正常終了  非0: 異常終了 */
var stmtfmt varchar2(2000);
declare
	/*
	 * 2000 バイトを超える文字列には未対応です。
	 */
	stmtorg varchar2(2000);
begin
	select text  /* 定義問合せの文字列 */
	into stmtorg
	from all_views 
	where owner = 'SYS' 
	and view_name = 'ALL_SYNONYMS'
	;
	/* 文を整形 */
	:ret := SQLFMT(stmtorg, chr(9), 14, 50, :stmtfmt);
end;
/
print
