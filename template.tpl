___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "displayName": "Trim Query",
  "description": "Returns a string obtained by deleting an arbitrary query from the specified variable.",
  "securityGroups": [],
  "categories": [
    "UTILITY"
  ],
  "id": "cvt_temp_public_id",
  "type": "MACRO",
  "version": 1,
  "containerContexts": [
    "WEB"
  ],
  "brand": {}
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "targetURL",
    "displayName": "Target URL",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "elementURL",
        "displayValue": "Element URL (Click URL, Form URL)"
      },
      {
        "value": "pageURL",
        "displayValue": "Page URL"
      },
      {
        "value": "pageURLAll",
        "displayValue": "Page URL All (Page URL + Fragment)"
      }
    ],
    "simpleValueType": true,
    "help": "Specify a choice or URL format variable.<br>\n<b>note:</b> Do not use the excerpt of only the query without '?' Or the excerpt of only the hash tag without '#'."
  },
  {
    "type": "GROUP",
    "name": "targetFrom",
    "displayName": "Remove from what",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "help": "Check to remove from the target variable query (\"? ~~\").",
        "alwaysInSummary": false,
        "defaultValue": true,
        "name": "query",
        "checkboxText": "Queries",
        "type": "CHECKBOX"
      },
      {
        "help": "Check to remove from the target variable fragment (\"# ~~\").",
        "defaultValue": false,
        "name": "hash",
        "checkboxText": "Fragment",
        "type": "CHECKBOX"
      }
    ]
  },
  {
    "name": "targetQueries",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Delete query key",
        "name": "query",
        "type": "TEXT",
        "isUnique": true,
        "valueHint": "e.g. _ga"
      }
    ],
    "type": "SIMPLE_TABLE"
  },
  {
    "type": "LABEL",
    "name": "helpText",
    "displayName": "The entered \"Delete query key\" is used judge by an exact match (\"equals\"), and if it matches, the key and value are deleted."
  }
]


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "gtm.elementUrl"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// -------- API required
const log = require('logToConsole');
log('data =', data);
// data.targetURL: (elementURL | pageURL | pageURLAll | {{variable}})
// data.query:true
// data.hash:true
// data.targetQueries:[{"query":"_ga"},{"query":"_gac"}]

// --------- Default Settings
// ---- Start Setting
var Var = data.targetURL;					// Target URL
const delQuery = data.targetQueries;			// Delete query key
const delTarget = [data.query, data.hash];	// Remove from what（0:Queries、1:Fragment）

// ---- Get Target URL
switch(Var){
	case 'elementURL':
		var get = require('copyFromDataLayer');
		Var = get('gtm.elementUrl');
		break;
	case 'pageURL':
		var get = require('getUrl');
		Var = get('protocol') +'://' + get('host') + get('path');
		if(get('query')){
			Var += '?' + get('query');
		}
		break;
	case 'pageURLAll':
		var get = require('getUrl');
		Var = get('protocol') +'://' + get('host') + get('path');
		if(get('query')){
			Var += '?' + get('query');
		}
		if(get('fragment')){
			Var += '#' + get('fragment');
		}
		break;
}
log('Var = ' + Var);

// --------- Processing
if(Var !== undefined){
	// ---- Split URL
	var path = Var.split('?')[0].split('#')[0];
	var query = null;
	var hash = null;
	if(Var.indexOf('?') >= 0){	// 1st '?' to before 1st '#'
		query = Var.split('?').shift().join('').split('#')[0];
	}
	if(Var.indexOf('#') >= 0){	// 1st '#' to end
		hash = Var.split('#').shift().join('');
	}

	// ---- Target Key query remove
	const omit = function(del, target, word){
		if(delTarget[del] && target){
			// Search & destroy
			var queries = target.split('&');		// Split query
			for(var i = queries.length - 1; i >= 0; i--){	// For Query length from end to start
				for(var j = 0; j < delQuery.length; j++){	// For Delete Query length from start to end
					if(queries[i].indexOf(delQuery[j].query + '=') === 0){
						// If: Checking Delete target is true
						queries.splice(i, 1);	// Target delete
						break;
					}
				}
			}
			if(queries.length >= 1){
				// If: Queries is be.
				target = queries.join('&');
			}else{
				// If: Queries is none.
				target = '';
			}
		}
		if(target){
			if(target.indexOf(word) !== 0){
				target = word + target;
			}
			path += target;
		}
	};

	omit(0, query, '?');	// Remove from queries.
	omit(1, hash, '#');	// Remove from fragment.

	// ---- Complete.
	return path;
}else{
	return undefined;
}


___NOTES___

This memo is written in two languages: English and Japanese.
このメモは、英語と日本語の2つの言語で書かれています。

The first half is English and the second half is Japanese.
前半は英語で、後半は日本語です。

Both will have the same content.
両方とも同じ内容になります。

Thank you Google Translate!
Google翻訳ありがとう！


----------------------------------------------------------------
For English
----------------------------------------------------------------

A custom variable template to return a string obtained by removing a query with a specified name from a link URL or page URL.
It is mainly used to delete unnecessary _ga queries when measuring link URL and page URL events.

● Operation overview
-Deletes the query specified by "Delete query key" from the variable specified by "Target URL" and returns it.
 (If nothing is deleted, the value of the variable specified in “Target URL” will be returned as is)

● Memo
-In the Target URL field, you can specify the following three items that are especially in demand without registering variables.
--Element URL (= Click URL, Form URL)
--Page URL （= Page URL)
--Page URL All （= Page URL + Fragment)
-In the Target URL field, in addition to the above three items, you can also select a specified variable.
-"Remove from what" is only "Queries" by default, but it is possible to delete from hashtags by checking "Fragment".
-The query name specified by "Delete query key" is judged by "exact match".
-If there is no part matching the query name specified in "Delete Query Key", or if "Delete Query Key" is not set, the target value specified in "Target URL" is returned as it is.
-This template was created by Ayudante, Inc. as the 1st draft.

● Editing history
[2019/10/18 (Update)] Ayudante, Inc.
-In order to create a community template, the language of each part has been changed from Japanese to English.

[2019/06/21(Update)] Ayudante, Inc.
-When saving a variable, the error message "Service error occurred" was displayed and a bug that could not be saved occurred, so the input rule for the "targetQueries" item was deleted.

[2019/05/24 (New)] Ayudante, Inc.
https://ayudante.jp/column/2019-05-24/18-04/
- It was new registration.


----------------------------------------------------------------
For Japanese	日本語
----------------------------------------------------------------

リンクURLやページURLなどから、指定した名前のクエリを除去した文字列を返すためのカスタム変数テンプレートです。
主にリンクURLやページURLをイベント計測したい場合などに、不要となる_gaクエリなどを抜くために使用することを想定しています。

●動作概要
・「Target URL」で指定した変数から、「Delete query key」で指定したクエリを削除したものを返します。
　（何も削除されなかった場合は「Target URL」で指定した変数の値がそのまま返ります）

●備考
・「Target URL」欄では特に需要の多い以下3つを変数登録不要で指定できます。
　　　・Element URL　（＝Click URL, Form URL）
　　　・Page URL　（＝Page URL）
　　　・Page URL All　（＝Page URL＋ハッシュタグ）
・「Target URL」欄では上記3項目の他、指定した任意の変数も対象に選択できます。
・除去対象（Remove from what）はデフォルトでは「Queries」のみとしていますが、
　「Fragment」にチェックを入れることでハッシュタグからも削除が可能です。
・「Delete query key」で指定するクエリ名は「完全一致」で判定しています。
・「Delete query key」で指定したクエリ名に合致する箇所がない、またはそもそも「Delete query key」が設定されていない場合は「対象変数」で指定した対象の値そのままが返ります。
・本テンプレートはアユダンテが1stドラフトを作成しました。

●編集履歴
【2019/10/18（更新）】Ayudante, Inc.
・コミュニティテンプレート化のため、各箇所の言語を日本語から英語へ変更しました。

【2019/06/21（更新）】Ayudante, Inc.
・変数の保存時に「サービスエラーが発生しました」とエラーメッセージが出て保存できないバグが発生していたため、「targetQueries」項目の入力規則を削除しました。

【2019/05/24（新規作成）】Ayudante, Inc.
https://ayudante.jp/column/2019-05-24/18-04/
・新規登録しました。
