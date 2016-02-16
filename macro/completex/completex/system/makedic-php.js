// 
// 		PHP の辞書を作る for CompleteX
// 		by IKKI  2009/09/10
// 

// [手順]
// 1. http://jp.php.net/get/php_manual_ja.tar.gz/from/this/mirror をダウンロードして解凍
// 2. コマンドプロンプトを開く
// 3. cd 解凍したフォルダ
// 4. cscript //nologo makedic-php.js html php.dic php.hint > log.txt

WScript.StdOut.WriteLine("辞書を更新しています...");

var fso = WScript.CreateObject("Scripting.FileSystemObject");
var args = WScript.Arguments;
docdir  = args(0);
dicfile = args(1);
hntfile = args(2);

var dic = openStream("Shift_JIS");
var hnt = openStream("Shift_JIS");

var d = fso.GetFolder(docdir);
var fc = new Enumerator(d.files);
for (var i = 1; !fc.atEnd(); fc.moveNext(), i++) {
	f = fc.item();
	if (f.Name.indexOf("function.") != 0) continue;
	
	WScript.StdOut.WriteLine(f.Path);
	content = loadText(f.Path, "UTF-8");
	
	// 関数のドキュメント
	a1 = content.match(/<h1 class="refname">(.*?)<\/h1>/i);
	if (a1) {
		putLine(dic, a1[1]);
		while (true) {
			a2 = content.match(/<\/h3>((.|[\r\n])*?)<(h[1-6]|hr|blockquote|div class="example")/im);
			if (!a2[1].match(/この関数は次の関数のエイリアスです/)) break;
			fpath = f.ParentFolder + "\\" + a2[1].match(/<a href="(.*?)"/i)[1];
			if (!fso.FileExists(fpath)) break;
			content = loadText(fpath, "UTF-8");
			WScript.StdOut.WriteLine("--> " + fpath);
		}
		putLine(hnt, a2[1]);
		continue;
	}
	// 制御構造のドキュメント
	a1 = content.match(/<h2 class="title">(.*?)<\/h2>/i);
	if (a1) {
		putLine(dic, a1[1]);
		a2 = content.match(/<\/h2>((.|[\r\n])*?)<(h[1-6]|hr|blockquote|div class="example")/im);
		putLine(hnt, a2[1]);
		continue;
	}
	WScript.StdErr.WriteLine("\n" + f.Path + " cannot be processed");
}
saveStream(dic, dicfile);
saveStream(hnt, hntfile);

function openStream(encoding) {
	var ado = WScript.CreateObject("ADODB.Stream");
	ado.Charset = encoding || "UTF-8";
	ado.Open();
	return ado;
}

function putLine(ado, text) {
	text = text.replace(/[ \t\r\n]+/gm, " ");
	text = text.replace(/<(p|div|blockquote)/g, "\n<$1");
	text = text.replace(/<.*?>/g, "");
	text = text.replace(/&lt;/g, "<");
	text = text.replace(/&gt;/g, ">");
	text = text.replace(/&amp;/g, "&");
	text = text.replace(/\\/gm, "\\\\");
	text = text.replace(/^[ \t\r\n]+/gm, "");
	text = text.replace(/[ \t\r\n]+$/gm, "");
	text = text.replace(/[\r\n]/gm, "\\n");
	ado.WriteText(text + "\n");
}

function saveStream(ado, filename) {
	ado.SaveToFile(filename, 2); // adSaveCreateOverWrite
	ado.Close();
}

function loadText(textpath, encoding) {
	var ado = WScript.CreateObject("ADODB.Stream");
	ado.Charset = encoding || "_autodetect";
	ado.Open();
	ado.LoadFromFile(textpath);
	var content = ado.ReadText();
	ado.Close();
	return content;
}
