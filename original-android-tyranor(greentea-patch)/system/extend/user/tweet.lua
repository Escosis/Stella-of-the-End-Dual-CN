----------------------------------------
-- twitter
----------------------------------------
tweet = {}
----------------------------------------
local ex = {
	sizew	= 430,		-- スクショサイズ
	sizeh	= 242,
	ssfile	= "tweet_thumb.png",
	twfile	= "tweet.png",
	address	= "http://acs.imel.co.jp/app/tweeting/stella/",

	-- thumb
	th_x	= 700 + 45,
	th_y	= 338 + 42,
	thhd_x	= 380 + 45,
	thhd_y	= 158 + 42,
	id		= 510,

	-- text
	commax	= 140,		-- コメント最大文字数
}
----------------------------------------
-- 
----------------------------------------
-- tweet画面作成
function user_tweet()
	-- logoを一瞬表示
	local px = ":ui/__sys_tw_overlap"
	local id = "tweet"
	lyc2{ id=(id), file=(px) }
	flip()

	local fl = ex.ssfile
	local fx = ex.twfile
	local w  = ex.sizew		-- mulpos(ex.sizew)
	local h  = ex.sizeh		-- mulpos(ex.sizeh)
	estag("init")
	estag{"eqwait",100}
	estag{"takess"}
	estag{"savess", file=(fl), width=(w), height=(h)}
	estag{"savess", file=(fx), width=(game.width), height=(game.height)}
	estag{"eqwait"}
	estag{"lydel2", id}
--	estag{"flip"}
	estag{"user_tweet2"}
	estag()
end
----------------------------------------
-- 表示
function user_tweet2()
	local id = ex.id
	local fl = ex.ssfile
	local px = e:var("s.savepath").."/"..fl		-- セーブフォルダ
--	local x  = mulpos(ex.th_x)
--	local y  = mulpos(ex.th_y)
	local x  = game.sp and ex.thhd_x or ex.th_x
	local y  = game.sp and ex.thhd_y or ex.th_y

	flg.ui = {}
	setonpush_ui()

	se_ok()
--	sliderdrag_stat(0)	-- ドラッグ禁止
	csvbtn3("user", id, lang.game_tweet)
	lyc2{ id=(id..".th.0"), x=(x), y=(y), file=(px) }
--	lyc2{ id=(id..".th.1"), x=(x), y=(y), file=":ui/mw/tweetlogo" }
	if not sys.uid then
		setBtnStat('bt_post', 'c')	-- 投稿
		setBtnStat('bt_coms', 'c')	-- コメント
		btn_clip('text', "clip")	-- text
		local tx = tweet.gettext("none")
		tweet.text(tx)				-- comment
	else
		btn_clip('text', "clip_a")	-- text
		local tx = tweet.gettext()
		tweet.text(tx)				-- comment
	end
	uiopenanime("tweet")
end
----------------------------------------
function user_tweetclick(e, p)
	local bt = p.bt or p.btn
	local v  = getBtnInfo(bt)
	local p1 = v.p1
	local sw = {

	-- 認証開始
	init = function()
		tweet_server()
		tweet.closewindow()
	end,

	post = function() tweet.start() end,		-- 投稿
	coms = function() tweet.comment() end,		-- コメント
	exit = function() tweet.closewindow() end,	-- 戻る
	}
	if sw[p1] then sw[p1]() end
end
----------------------------------------
-- window close
function tweet.closewindow()
--	sesys_stop("pause")		-- SE一時停止
	se_cancel()
	sesys_resume()			-- se再開
--	sliderdrag_stat(1)		-- ドラッグ許可
	scr.uifunc = nil
	flg.ui = nil

	delonpush_ui()			-- key戻し
	tweet.text("del")		-- text消去
	delbtn('user')
	init_adv_btn()			-- ボタン設置
	autoskip_init()			-- skip init
	uiopenanime("tweet")
end
----------------------------------------
-- text
function tweet.text(tx)
	local id = ex.id..".tx"
	if tx == "del" then
		ui_message(id)
	else
		ui_message(id, { 'tweet', text=(tx)})
	end
end
----------------------------------------
-- comment
function tweet.comment()
	local tx = tweet.gettext()
	tag_dialog({ title="tweetcomment", varname="t.yn", textfield="t.tx", textfieldsize=(ex.commax), message=(tx) }, "user_tweetnext")
end
----------------------------------------
function user_tweetnext()
	local yn = tn(e:var("t.yn"))
	local tx = e:var("t.tx")
	tag{"var", system="delete", name="t.yn"}
	tag{"var", system="delete", name="t.tx"}
	if yn == 1 then
		se_ok()
		if tx == "" then tx = nil end
		sys.tweettext = tx
		tweet.text(tweet.gettext())
		flip()
	else
		se_cancel()
	end
end
----------------------------------------
-- text取得
function tweet.gettext(flag)
	local tx = sys.tweettext
	if flag == "none" or not tx then
--	elseif not tx then
--		local t  = getTextBlockText()	-- テキスト取得
--		local ln = get_language()
--		tx = t[ln]
--		flag = true

		-- ロゴ
		local v  = lang.uihelp.system
		local nm = getTrial() and "tweet_trial" or "tweet"
		tx = v[nm]
	end
	return tx
end
----------------------------------------
--
----------------------------------------
function tweet.get_address(name, flag)
	local px = ex.address..name..".php"
	if flag then
		px = px.."?uid="..tweet.get_uid()
	end
	return px
end
----------------------------------------
function tweet.get_uid()
	local uid = sys.uid
	if not uid then
		local tbl = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
		local r1 = e:random() % 26 + 1
		local r2 = e:random() % 26 + 1
		local r3 = e:random() % 26 + 1
		uid = tbl[r1]..tbl[r2]..tbl[r3]..e:now()
		sys.uid = uid
		message("通知", "uid生成", uid)
		asyssave()
	end
	return uid
end
----------------------------------------
--
----------------------------------------
-- キャプチャして投稿
function tweet.start()
	if not sys.uid then
		tweet_server()
	else
		estag("init")
--		estag{"takess"}	-- SSをメモリに保存
--		estag{"savess", file=(ex.ssfile), width=(ex.sizew), height=(ex.sizeh)}
		estag{"eqwait"}
		estag{"tweet_postnext"}
		estag()
	end
end
----------------------------------------
function tweet_postnext()
--	local addr = "http://imel.co.jp/app/tweetimg/check_tweetable.php?uid="..get_uid()
	local addr = tweet.get_address("check_tweetable", true)
	eqtag{"httpget", url=(addr), 
		varname_code = "t.hostcode",
		varname_data = "t.hostdata"
	}
	eqtag{"calllua", ["function"]="checkServerStatus", lua="tweet_postnext2", err="tweet_server"}
end
----------------------------------------
function tweet_postnext2()
--	local v    = getLangHelp("system")
--	local name = getTrial() and "tweet_trial" or "tweet"
--	local text = v[name]
	local file = e:var("s.savepath").."/"..ex.twfile
	if not debug_flag and isFile(file) then
		eqtag{"httppost",
--			url		= "http://imel.co.jp/app/tweetimg/tweet.php",
			url		= tweet.get_address("tweet"),
			key0	= "uid",
			value0	= tweet.get_uid(),
			key1	= "text",
			value1	= tweet.gettext(),
			key2	= "image",
			file2	= file,
			varname_code="t.hostcode",
			varname_data="t.hostdata",
		}
		eqtag{"calllua", ["function"]="checkServerStatus", lua="tweet_postend"}
	else
		dialog("ngtweet")
		if debug_flag then
			sysmessage("警告", "デバッグモードではtweetできません")
		end
	end
end
----------------------------------------
function tweet_postend()
	dialog("oktweet")
end
----------------------------------------
-- 
function tweet_server()
--	local addr = "http://imel.co.jp/app/tweetimg/auth.php?uid="..get_uid()
	local addr = tweet.get_address("auth", true)
	eqtag{"openbrowser", url=(addr)}
end
----------------------------------------
-- 鯖チェック
function checkServerStatus(e, p)
	local code = e:var("t.hostcode")
	local data = e:var("t.hostdata")
	if code ~= "200" then message("status", code, data) end
	if code == "200" then	 eqtag{"calllua", ["function"]=(p.lua)}
	elseif code == "-3" then eqtag{"calllua", ["function"]=(p.lua)}
	elseif p.err then		 eqtag{"calllua", ["function"]=(p.err)}
	else dialog("ngtweet") end
end
----------------------------------------
