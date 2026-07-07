----------------------------------------
-- タイトル画面
----------------------------------------
local exid = "500.a"
----------------------------------------
function title_init()
	gscr.logo = 1
	flg.title = {}

	ClearMemory("start")		-- ガベージコレクト開始

	----------------------------------------
	-- 判定
	local ex1 = gscr.clear
	if not getTrial() and not ex1 then

--		if(G[201] == 0){back.object[41].set_button_state_disable}			cahpter
--		if(<GAME_CLEAR> == 0){back.object[44].set_button_state_disable}		extra

		-- chapter開放チェック
		local ex01 = gscr.chapter
		local ax01 = tn(get_eval("g.chap02"))		-- @アイキャッチ(2)
		if ax01 == 1 then
			gscr.chapter = true
		end

		-- おまけ開放チェック
		local ex02 = gscr.extraopen
		local ax02 = tn(get_eval("g.game_clear"))	-- <GAME_CLEAR>
		if not ex02 and ax02 == 1 then
--			bgm_unlock{ file="bgm48" }
			gscr.extraopen = true
			gscr.clear = 1
			gscr.evset.ts98 = true
			gscr.evset.ts99 = true
			gscr.ev.staffroll = true
			gscr.ev.op01 = true
		end
	end
	local route = "title01"							-- 通常
	if getTrial() then			route = "trial"		-- 体験版
	elseif gscr.clear then		route = "title02"	-- 全クリ
	end
	flg.title.route = route

	message("通知", "タイトル画面を開きました", route)

	----------------------------------------
	extra = nil				-- シーン用
	flg.skip = nil			-- ctrlskipフラグを倒しておく
	scr.mw.mode = nil
	flg.extra_bgm = nil		-- bgm再生番号とか

	----------------------------------------
	-- uiの初期化
	local tbl = {
		title01="ui_title01",	-- 通常
		title02="ui_title01",	-- 全クリ
		trial  ="ui_title01"	-- 体験版
	}
	csvbtn3("ttl1", "500", lang[tbl[route]])
	screen_crop("500")
--	title_load2info()
	scr.uifunc = 'ttl1'

	if not gscr.chapter then setBtnStat('bt_chap', 'c') end
	if not gscr.clear	then setBtnStat('bt_extra', 'c') end

	-- ボタンを初期化しておく
	flg.ui = {}
	setonpush_ui(true)

	-- exit
--	local ox = game.os
--	if ox == "ios" or ox == "wasm" then
--		setBtnStat('bt_exit', 'c')
--		tag{"lyprop", id=(getBtnID("bt_exit")), visible="0"}
--	end

	-- 課金ボタン
	local g = gscr.shop
	if g and game.sp then
		local z  = csv.list_shop
		local ct = 0
		local mx = 0
		for nm, v in pairs(z) do
			if g[nm] then ct = ct + 1 end
			mx = mx + 1
		end
		if ct == mx then setBtnStat('bt_exit', 'c') end
	end

	----------------------------------------
	-- ボタン開放
--	if sv.checkopen("cont" ) then setBtnStat('bt_load2', 'c') end	-- セーブデータがない
--	if sv.checkopen("quick") then setBtnStat('bt_qload', 'c') end	-- qsaveのデータがない
--	if sv.checkopen("auto" ) then setBtnStat('bt_qload', 'c') end	-- オートセーブのデータがない
--	if sv.checkopen("cont" ) then setBtnStat('bt_cont' , 'c') end	-- 最新のセーブデータ
--	if sv.checkopen("title") then setBtnStat('bt_load' , 'c') end	-- 最新のセーブデータ及びオートモード

	----------------------------------------
	-- タイトル振り分け
	local sw = {

		-- 通常
		title01 = function()
			tag{"video", id=(exid), file=":ani/ef_dust05.ogv", loop="1"}
			tag{"lyprop", id=(exid), layermode="screen"}
			tag{"lyprop", id=(getBtnID("ch02")), visible="0"}
--			if not gscr.extraopen then setBtnStat('bt_extra' , 'c') end
		end,

		title02 = function()
--			tag{"video", id=(exid), file=":ani/ef_flare20.ogv", loop="1"}
			tag{"lyprop", id=(getBtnID("ch01")), visible="0"}
		end,

		-- 体験版
		trial = function()

		end,
	}
--	title_page()
	if sw[route] then sw[route]() end

	----------------------------------------
	-- 画面を表示する
	ResetStack()
	autoskip_ctrl()
	estag("init")

	-- アニメoff もしくはui画面から戻った
	if titlepage or conf.sysani == 0 or flg.title.page then
--		estag{"uitrans"}
		estag{"uiopenanime", "extr"}
		estag{"title_bgm"}
		estag{"titlecall"}

	-- 画面をアニメーションする
	elseif route == "trial" then
		estag{"uitrans", 1000}
		estag{"title_bgm"}
		estag{"titlecall"}
	else
		title_skipset(true)				-- skip許可
		estag{"title_animeset", route}
		estag{"uitrans", 1000}
		estag{"title_bgm"}
		estag{"title_anime", route}
		estag{"title_skipset"}			-- skip解除
--		estag{"title_cursor"}			-- ボタンアクティブ
	end
	estag{"allkeyon"}
	estag{"autoskip_ctrl", true}
	estag{"jump", file="system/ui.asb", label="stop" }
	estag()
end
----------------------------------------
function title_animeset(md)
	tag{"lyprop", id=(getBtnID("bt_start")), alpha="0"}
	tag{"lyprop", id=(getBtnID("bt_chap" )), alpha="0"}
	tag{"lyprop", id=(getBtnID("bt_load" )), alpha="0"}
	tag{"lyprop", id=(getBtnID("bt_conf" )), alpha="0"}
	tag{"lyprop", id=(getBtnID("bt_extra")), alpha="0"}
	tag{"lyprop", id=(getBtnID("bt_exit" )), alpha="0"}
--	tag{"lyprop", id=(getBtnID("logo01")), alpha="0"}
	tag{"lyprop", id=(getBtnID("logo02")), alpha="0"}
	tag{"lyprop", id=(getBtnID("ch01")), alpha="0"}
	tag{"lyprop", id=(getBtnID("ch02")), alpha="0"}
	tag{"lyprop", id=(getBtnID("bg")), top="0"}

	-- logo
	local v  = getBtnInfo('logo01')
	tag{"lyprop", id=(v.idx), alpha="0", anchorx=(v.w / 2), anchory=(v.h / 2)}

	-- white
	lyc2{ id="500.zzmask", file=(init.white), layermode="screen"}
	uitrans(1000)
end
----------------------------------------
function title_anime(md)
	-- フレア
	if md == "title02" then
		tag{"video", id=(exid), file=":ani/ef_flare20.ogv"}
		tag{"lyprop", id=(exid), layermode="screen"}
		systween{ id=(exid), time="7000", alpha="255,0", ease="none" }
		flip()
	end

	local tm01 = 7000
	local tm02 = 1000
	local tm03 = tm01 + tm02
	local tm04 = 150
	local v  = getBtnInfo('bg')
	systween{ id=(v.idx), y=("0,"..v.y), time=(tm01), ease="none"}
	systween{ id="500.zzmask", alpha="255,0", time="5000", ease="out"}

	-- logo
	local id01 = getBtnID("logo01")
	local id02 = getBtnID("logo02")
	local id03 = getBtnID("ch01")
	local id04 = getBtnID("ch02")
	systween{ id=(id01), time=(tm02), delay=(tm01), zoom="110,100" }
	systween{ id=(id01), time=(tm02), delay=(tm01), alpha="0,255", ease="in" }
	systween{ id=(id02), time=(tm02), delay=(tm01), alpha="0,255", ease="in" }
	systween{ id=(id03), time=(tm02), delay=(tm01), alpha="0,255", ease="in" }
	systween{ id=(id04), time=(tm02), delay=(tm01), alpha="0,255", ease="in" }

	-- btn
	local bt01 = getBtnInfo("bt_start")
	local bt02 = getBtnInfo("bt_chap")
	local bt03 = getBtnInfo("bt_load")
	local bt04 = getBtnInfo("bt_conf")
	local bt05 = getBtnInfo("bt_extra")
	local bt06 = getBtnInfo("bt_exit")
	local xx   = bt01.x
	local x    = (xx - mulpos(200))..","..xx
	systween{ id=(bt01.idx), time=(tm02), delay=(tm03 + tm04*0), alpha="0,255", ease="in" }
	systween{ id=(bt02.idx), time=(tm02), delay=(tm03 + tm04*1), alpha="0,255", ease="in" }
	systween{ id=(bt03.idx), time=(tm02), delay=(tm03 + tm04*2), alpha="0,255", ease="in" }
	systween{ id=(bt04.idx), time=(tm02), delay=(tm03 + tm04*3), alpha="0,255", ease="in" }
	systween{ id=(bt05.idx), time=(tm02), delay=(tm03 + tm04*4), alpha="0,255", ease="in" }
	systween{ id=(bt06.idx), time=(tm02), delay=(tm03 + tm04*5), alpha="0,255", ease="in" }
	systween{ id=(bt01.idx), time=(tm02), delay=(tm03 + tm04*0), x=(x) }
	systween{ id=(bt02.idx), time=(tm02), delay=(tm03 + tm04*1), x=(x) }
	systween{ id=(bt03.idx), time=(tm02), delay=(tm03 + tm04*2), x=(x) }
	systween{ id=(bt04.idx), time=(tm02), delay=(tm03 + tm04*3), x=(x) }
	systween{ id=(bt05.idx), time=(tm02), delay=(tm03 + tm04*4), x=(x) }
	systween{ id=(bt06.idx), time=(tm02), delay=(tm03 + tm04*5), x=(x) }
	eqwait(tm02 + tm03 + tm04*5)
end
----------------------------------------
-- タイトルアニメーションをskipしたときの動作
function title_skipset(flag)
	if flag then
		tag{"skip", allow="1"}
		flg.title.skip = true
	elseif flg.title.skip then
		tag{"skip", allow="0"}
		flg.title.skip = nil

		if flg.title.skipflag then
			tag{"lytweendel", id=(getBtnID("bt_start"))}
			tag{"lytweendel", id=(getBtnID("bt_chap"))}
			tag{"lytweendel", id=(getBtnID("bt_load"))}
			tag{"lytweendel", id=(getBtnID("bt_conf"))}
			tag{"lytweendel", id=(getBtnID("bt_extra"))}
			tag{"lytweendel", id=(getBtnID("bt_exit"))}
			tag{"lytweendel", id=(getBtnID("logo01"))}
			tag{"lytweendel", id=(getBtnID("logo02"))}
			tag{"lytweendel", id=(getBtnID("ch01"))}
			tag{"lytweendel", id=(getBtnID("ch02"))}
			tag{"lytweendel", id=(getBtnID("bg"))}
			tag{"lytweendel", id="500.zzmask"}
			tag{"lytweendel", id=(exid)}
			flg.title.skipflag = nil
		end
	end
end
----------------------------------------
-- ボタンセット入れ替え
function title_btnchange(name)
	local sw = {

	-- extra
	extra = function()
		flg.title.page = true
		title_page()
		uitrans()
	end,

	-- 体験版
	trial = function()
		if game.pa then
			flg.title.page = true
			title_page()
			uitrans()
		end
	end,
	}
	if sw[name] then sw[name]() end
end
----------------------------------------
-- ボタンセット入れ替え / 閉じる
function title_btnsetexit()
	if flg.title.page then
		se_cancel()
		flg.title.page = nil
		title_page()
		uitrans()
	elseif game.exitbtn then
		adv_exit()
	end
end
----------------------------------------
-- omake
function title_page()
	local p = flg.title.page
	if not p then
		e:tag{"lyprop", id="500.s", visible="0"}
		e:tag{"lyprop", id="500.d", visible="1"}
	else
--			local path = game.path.ui.."title/trbg"
--			lyc2{ id="500.tr.0", file=(path) }
		e:tag{"lyprop", id="500.s", visible="1"}
		e:tag{"lyprop", id="500.d", visible="0"}
	end
end
----------------------------------------
--
----------------------------------------
-- BGM制御
function title_bgm()
	local rt = flg.title and flg.title.route
	local b  = rt and init["titlebgm_"..rt] or init.titlebgm_title
	local no = getTrial() and 2 or 1
	local t  = type(b)
	local sw = {
		["table"] = function()	bgm_play{ file=(b[no]) } end,
		["string"] = function()	bgm_play{ file=(b) } end,
	}
	if sw[t] then sw[t]() end
end
----------------------------------------
-- 音声ランダム
function titlecall()
	if not titlepage and not flg.title.page then
		local nm = init.trial and "trial" or "titlecall"
		sysvo(nm)
	end
end
----------------------------------------
-- 終了処理
function title_close()
	delbtn('ttl1')		-- 削除
	flg.title = nil
end
----------------------------------------
-- 続きからの状態を表示
function title_load2info(flag)
--[[
	local id = getBtnID("info")
	if id then
		if sv.checkopen("cont") then
			tag{"lyprop", id=(id), visible="0"}
		elseif not flag then
			local s  = sys.saveslot
			local no = s.cont
			local t  = s[no]

			-- thumb
			local path = e:var("s.savepath")..'/'	-- savepath
			local ss   = csv.mw.savethumb			-- サムネイル位置
			local th   = path..t.file
			local thid = id..".1"					-- サムネイルid
			lyc2{ id=(thid..".0"), file=(th), x=(ss.x), y=(ss.y)}

			-- HEVマスク
			local evm = t.evmask
			if init.game_evmask and evm then
				local pppx = ":evmask/"..evm
				lyc2{ id=(thid..".1"), file=(pppx), x=(ss.x), y=(ss.y)}
			end

			-- text
			local ln   = get_language(true)				-- 言語
			local mt   = init.save_message_max or 100	-- 文字数
			local tx   = t.text
			local time = get_osdate("%Y/%m/%d %H:%M", t.date)
			local tttl = sv.changesavetitle(t.title or {})
			local tttx = t.com or tx[ln] or tx.text or ""
			if tx.select then tttx = get_langsystem("select")			-- 選択肢
			elseif ad and tx.name then tttx = (tx.name[ln] or tx.name.name or "")..tttx end
			tttx = mb_substr(tttx, 1, mt)
			ui_message((id..'.20'), { 'loadno', text="Continue"})		-- セーブNo
			ui_message((id..'.21'), { 'loadday',text=(time)})			-- セーブ日付／ゲーム内
			ui_message((id..'.22'), { 'load'   ,text=(tttx)})			-- セーブテキスト
			ui_message((id..'.23'), { 'loadttl',text=(tttl)})			-- セーブタイトル
			tag{"lyprop", id=(id), visible="0"}
		else
			ui_message(id..'.20')
			ui_message(id..'.21')
			ui_message(id..'.22')
			ui_message(id..'.23')
		end
	end
]]
end
----------------------------------------
function title_over2() tag{"lyprop", id=(getBtnID("info")), visible="1"} end
function title_out2()  tag{"lyprop", id=(getBtnID("info")), visible="0"} end
----------------------------------------
-- アクティブ制御
----------------------------------------
-- アクティブボタン制御
function title_cursor()
	if game.os ~= "android" then
		local s = titlepage or game.cs and 'bt_start'
		if s then btn_active(s) end
	end
end
----------------------------------------
function title_helpover(e, p)
	local nm = p.name or btn.cursor
	if nm then
		local v1 = getBtnInfo(nm)
		local v2 = getBtnInfo("message")
		local p2 = tn(v1.p2)
		local clip = v2.cx..","..(v2.cy + v2.ch * p2)..","..v2.cw..","..v2.ch
		tag{"lyprop", id="500.help", visible="1", clip=(clip)}
		flg.title.help = nm
	end
end
----------------------------------------
function title_helpout(e, p)
	local nm = p.name or btn.cursor
	local sp = flg.title.help
	if nm and nm == sp and game.os ~= "android" then
		tag{"lyprop", id="500.help", visible="0"}
		flg.title.help = nil
	end
end
----------------------------------------
-- ボタン類
----------------------------------------
-- クリック動作
function title_click(e, param)
	local bt = btn.cursor
	if bt then
--		message("通知", bt, "が選択されました")
		flg.tsysse = nil
		flg.titlemovie = nil
		titlepage = bt

		local v = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = v.p2
		local sw = {
			start = function() se_ok() sysvo(v.p3)			title_start(p2) end,	-- スクリプト開始
			load  = function() se_ok() 						adv_load() end,			-- load画面
			qload = function() se_ok()						adv_qload() end,		-- qload
			conf  = function() se_ok() 						adv_config() end,		-- config画面
			exit  = function() se_ok()						adv_exit()  end,		-- 終了
			info  = function() se_ok()						adv_info() end,			-- info
			cont  = function() se_ok() sysvo("load2")		title_load() end,		-- 最新の続きから

			chap  = function() se_ok()						user_chapter() end,		-- chapter

			trial = function() se_ok() sysvo("extra")	title_btnchange("trial") end,	-- 体験版おまけ
			extra = function() se_ok() 					title_btnchange("extra") end,	-- おまけ
			cg    = function() se_ok()					title_extra("cgmd") end,
			scene = function() se_ok()					title_extra("scen") end,
			bgm   = function() se_ok()					title_extra("bgmd") end,
		}
		if sw[p1] then sw[p1]() end
	end
end
----------------------------------------
-- extra呼び出し
function title_extra(nm)
	-- 体験版
	if getTrial() then


	-- 本編
	else
		local name = nm or init.extra_pagesave == "on" and gscr.extraname or "cgmd"
		extra_init(name, "title")
	end
end
----------------------------------------
-- 前回のつづきから
function title_auto()
	local no = sys.saveslot.cont
	if no then
		local p = get_savedatatime(no)
		if p then
			se_ok()
			e:tag{"var", name="t.file", data=(p.file..".dat")}
			e:tag{"call", file="system/ui.asb", label="title_autoload"}
		else
			e:tag{"dialog", title="通知", message="最新のセーブデータが見つかりませんでした"}
		end
	end
end
----------------------------------------
-- 最後にセーブされたデータを読み出す
function title_load()
	local v = sys.saveslot or {}
	local f = v.cont
	if f then
		sv.load(f, { mode="cont" })
	end	
end
----------------------------------------
-- ムービー再生
function title_movie()
	local time = 1500
	allkeyoff()
	bgm_stop{ time=(time) }
	lyc2{ id="900", file=(init.black) }
	tag{"var", name="t.time" , data=(time)}
	tag{"var", name="t.movie", data=(init.title_movie)}
	tag{"jump", file="system/ui.asb", label="title_automovie"}
end
----------------------------------------
function title_movieend()
	tag{"return"}
	tag{"lydel", id="900"}
	title_init()
end
----------------------------------------
-- ボタン類
----------------------------------------
-- ゲーム開始
function title_start(nm)
	local file = init[nm] or nm
	titlepage = nil
	allkeyoff()			-- キー停止
	autoskip_disable()	-- autoskip停止

	--------------------------------
	-- 起動
	--------------------------------
	estag("init")
	estag{"title_reset"}
	estag{"eqwait", 1000}
	estag{"sysvowait", { wait=true }}	-- sysvo待機
	estag{"title_start2", file}
	estag()
end
--------------------------------
function title_reset()
	-- uiの初期化
	title_load2info(true)
	delbtn('ttl1')		-- 削除

	-- fadeout
	local time = init.start_fadetime or init.bgm_fade
	allsound_stop{ mode="se", time=(time) }

	-- 背景
	local s	= init.start_bg or "black"
	local dtbg = init[s] or s

	-- delete
	tag{"lydel", id="1"}
	tag{"lydel", id="500"}
	tag{"lydel", id="600"}
	tag{"lydel", id="ui"}
	lyc2{ id="startmask", file=(dtbg)}
	uitrans(time)

	-- cache削除
	title_cachedelete()
	ClearMemory("stop")		-- ガベージコレクト停止
end
--------------------------------
-- スクリプトファイルを呼び出す
--------------------------------
function title_start2(nm)
	-- スタックを空にしておく／[return]でfirst.iet*topに戻る
	ResetStack()

	----------------------------------------
	-- 内部変数初期化
	appex = nil
	extra = nil
	scr = nil
	vartable_init()
	reset_backlog()
	key_reset()
	sv.delpoint()		-- セーブ情報を念のため初期化しておく
	----------------------------------------

	-- adv[]を初期化
	adv_flagreset()

	-- 念のため削除
	e:tag{"lydel", id="1"}

	-- 白bg
	local b = init.start_bg or "black"
	lyc2{ id="startmask", file=(init[b])}

--	loading_off()
--	flip()

	-- キー許可
--	allkeyon()

	-- スクリプトを呼び出す
	ast = nil
	scr.ip = nil
	local file = init.trial and init.trial_script or nm

	message("通知", file, "を呼び出します", no)
	readScriptStart(file, nil, v)
	return 1
end
----------------------------------------
-- 動画自動再生
function title_automovieset()
	flg.titlemovie = e:now() + init.automovie
end
----------------------------------------
function title_automovie()
	allkeyoff()
	bgm_stop{}			-- 次の曲
	tag{"var", name="t.bg", data=(init.black)}
	tag{"jump", file="system/ui.asb", label="title_automovie"}
end
----------------------------------------
function title_automovieend()
	title_init()
end
----------------------------------------
-- 起動時にスクリプトを実行
function getScriptStartup()
	local f = init.startup_script
	if f then
		local n = init.startup_flag
		if n and tn(e:var("g."..n)) == 1 then f = nil end
	end
	return f
end
----------------------------------------
--
----------------------------------------
function getTitle()
	local ret = nil
	if flg.title then ret = true end
	return ret
end
----------------------------------------
function getExtra()
--	local ret = extra and true or sys.extra and sys.extra.event
	local ret = scr.eventflag or appex and true or extra and true or sys.extra and sys.extra.event
	return ret
end
----------------------------------------
function getTrial()
	return init.trial == "on"
end
----------------------------------------
function getOSMode()
	local g = game.os
	local r = { os=g }
	if getTrial() then r.trial = true end					-- 体験版
	if init.allages == "on" then r.allages = true end		-- 全年齢
	if g == "windows" then
		if init.steam     == "on" then r.steam = true end	-- Steam版
		if init.dmmplayer == "on" then r.dmm   = true end	-- DMM Player版
		if init.softdc    == "on" then r.softdc= true end	-- ソフト電池
	end
	return r
end
----------------------------------------
