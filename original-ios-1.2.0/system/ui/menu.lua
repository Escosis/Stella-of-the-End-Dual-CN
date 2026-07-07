----------------------------------------
-- メニュー
----------------------------------------
-- メニューを開く
function menu_init()
	message("通知", "右クリックメニューに入りました")

	-- メニューフラグon
	if not scr.menu then scr.menu = {} end

	-- ボタン描画
	menu_button()
	menu_open()
end
----------------------------------------
-- ボタン設置
function menu_button()
	local v = lang.ui_menu
	csvbtn3("menu", "500", v)
	scr.menu.bmax = v[2] or 1			-- ボタン数
	scr.menu.move = v[3] or "x"			-- ボタンスクロール方向
	scr.menu.size = v[4] or 100			-- ボタンスクロールサイズ
	menu_refresh()						-- ボタン制御
--	set_uihelp("500.help", "menuhelp")	-- ui helpを使用する場合に有効化する
end
----------------------------------------
-- ボタンを塞ぐ処理
function menu_refresh(flag)
	check_adv_btn("menu")

	-- cs
	local bt = btn.cursor
	if bt and game.cs then btn_active2(bt) end

	-- flip
	if flag then flip() end
end
----------------------------------------
-- 画像描画
function menu_open()
--[[
	-- プレイ時間
	save_playtime()
	local t = math.floor(gscr.playtime / 1000)
	local h = math.floor(t / 3600)
	local m = math.floor((t%3600) / 60)
	local s = t % 60
	local tm = h
	if h < 100 then tm = string.format("%02d", h) end
	tm = "Playtime "..tm..":"..string.format("%02d", m)--..":"..string.format("%02d", s)

	message("通知", tm, t, h, m, s)

	local z  = sv.changesavetitle()			-- セーブタイトル
	set_textfont("playtime", "time")
	if z then	menu_playtime(z.."\n"..tm)
	else		menu_playtime("\n"..tm) end
]]
	menu_active()

	----------------------------------------
	-- 描画
	local nm = scr.menuopen
	if nm then
		-- uiから戻ってきた
		scr.menuopen = nil
		flg.ui.transflag = nil

		lyc2{ id="500.-1", file=(init.black), alpha="128" }
		uitrans()
	else
		local tm = init.ui_fade
		local ib = "500.-3"
		local iw = "500.-2"
		local ix = "500.-1"
		tag{"video", id=(ix), file=":ani/ef_noise3.ogv" }
		tag{"lyprop", id=(ix), xscale="200", yscale="200", layermode="screen"}
		tag{"lytweendel", id=(ix)}
		systween{ id=(ix), delay="1000", time="500", alpha="255,0", delete=1 }
		tag{"lyprop", id="500.mn", visible="0", anchorx=(game.ax), anchory=(game.ay)}
		tag{"lyprop", id=(getBtnID("btn01")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn02")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn03")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn04")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn05")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn06")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn07")), alpha="0"}
		tag{"lyprop", id=(getBtnID("btn08")), alpha="0"}
		siglus_titlebtn("btn08")
		lyc2{ id=(ib), file=(init.black), alpha="128"}
		lyc2{ id=(iw), file=(init.white)}
		systween{ id=(iw), alpha="0,128,0", time=(tm)}
		estag("init")
--		estag{"lyc2", { id=(id), file=(init.white), alpha="128" }}
		estag{"uitrans", { rule="rule500", time=(tm) }}
--		estag{"lyc2", { id=(id), file=(init.black), alpha="128" }}
		estag{"lyprop", id="500.mn", visible="1"}
		estag{"menu_openanime"}
		estag{"uitrans", (tm)}
		estag()
--[[
		-- anime
		local z  = scr.menu
		local mx = z.bmax		-- ボタン数
		local mv = z.move		-- ボタンスクロール方向
		local sz = z.size		-- ボタンスクロールサイズ
		local tm = init.ui_fade
		local ct = 0

		-- 全体
		if mx <= 1 then
			local id = "500.mn"
			if mv == "x" then tag{"lyprop", id=(id), left=(sz)} end
			if mv == "y" then tag{"lyprop", id=(id), top =(sz)} end
			tag{"lyprop", id="time", alpha="0"}
			flip()

			systween{ id=(id), [mv]=(sz..",0"), time=(tm) }

		-- ボタンごと
		else
			local v  = getBtnInfo("btn01")
			local x1 = v.x
			local x2 = v.w + x1
			for i=1, mx do
				tag{"lyprop", id=(getBtnID("btn0"..i)), left=(x2)}
			end
			tag{"lyprop", id="time", alpha="0"}
			flip()

			-- move
			for i=1, mx do
				systween{ id=(getBtnID("btn0"..i)), [mv]=(x2..","..x1), time=(tm), delay=(ct) }
				ct = ct + 20
			end
		end

		-- back
		lyc2{ id="500.-1", file=(init.black), alpha="128" }
		estag("init")
		estag{"uitrans", (tm + ct)}
		estag{"systween", { id="time", alpha="0,255", time=(tm) }}
		estag()
]]
	end
end
----------------------------------------
-- 
function menu_openanime()
	local tm = init.ui_fade
	local tx = 500
	local dl = 50
	systween{ id="500.mn", zoom="75,100", time=(tm)}
	systween{ id=(getBtnID("btn01")), time=(tx), alpha="0,255", delay=(dl*0), time=(tm)}
	systween{ id=(getBtnID("btn02")), time=(tm), alpha="0,255", delay=(dl*1), time=(tm)}
	systween{ id=(getBtnID("btn03")), time=(tm), alpha="0,255", delay=(dl*2), time=(tm)}
	systween{ id=(getBtnID("btn04")), time=(tm), alpha="0,255", delay=(dl*3), time=(tm)}
	systween{ id=(getBtnID("btn05")), time=(tm), alpha="0,255", delay=(dl*4), time=(tm)}
	systween{ id=(getBtnID("btn06")), time=(tm), alpha="0,255", delay=(dl*5), time=(tm)}
	systween{ id=(getBtnID("btn07")), time=(tm), alpha="0,255", delay=(dl*6), time=(tm)}
	systween{ id=(getBtnID("btn08")), time=(tm), alpha="0,255", delay=(dl*7), time=(tm)}
end
----------------------------------------
-- ボタンをアクティブにする
function menu_active()
	local bt = scr.menu.bt
	if bt and game.cs then btn_active2(bt) end
end
----------------------------------------
-- 
function menu_playtime(text)
	e:tag{"chgmsg", id="time", layered="1"}
	e:tag{"rp"}
	if text then e:tag{"print", data=(text)} end
	e:tag{"/chgmsg"}
end
----------------------------------------
-- メニューから抜ける
function menu_close()
	message("通知", "右クリックメニューから抜けました")

	-- SE
	local func = flg.closecom
	if func then
		se_ok()
		flg.stopsysse = true
	else
		se_cancel()
	end

	-- close
	estag("init")
--[[
	tag{"lytweendel", id="time"}
	local z  = scr.menu
	local mx = z.bmax		-- ボタン数
	local mv = z.move		-- ボタンスクロール方向
	local sz = z.size		-- ボタンスクロールサイズ
	local tm = init.ui_fade
	local ct = 0
	if mx <= 1 then
		local id = "500.mn"
		systween{ id=(id), [mv]=("0,"..sz), time=(tm) }
	else
		local v  = getBtnInfo("btn01")
		local x1 = v.x
		local x2 = v.w + x1
		for i=1, mx do
			systween{ id=(getBtnID("btn0"..i)), [mv]=(x1..","..x2), time=(tm), delay=(ct) }
			ct = ct + 20
		end
	end
	tag{"lyprop", id="500.-1", alpha="0"}
	tag{"lyprop", id="time"  , alpha="0"}
	estag{"uitrans", tm + ct}
]]
	estag{"menu_reset"}		-- ボタン情報を消す
	estag{"uitrans", tm}
	estag{"menu_delete"}	-- セーブ情報を消す
	estag()
	scr.menu = nil			-- メニューフラグoff
end
----------------------------------------
-- 状態クリア
function menu_reset()
--	del_uihelp()		-- ui help消去／使用する場合は有効化
	delbtn('menu')		-- ボタン消去
	menu_playtime()		-- playtime文字
	lydel2("time")		-- playtime画像
end
----------------------------------------
function menu_delete()
	sv.delpoint()		-- セーブ情報を消す
	flip()
end
----------------------------------------
-- menuを抜けて機能呼び出し
function menu_callfunc(name)
	flg.closecom = "adv_"..name
	close_ui()
end
----------------------------------------
-- メニューボタンがクリックされた
function menu_click(e, param)
	local bt = btn.cursor
	if bt then
--		message("通知", bt, "が選択されました")

		local v = getBtnInfo(bt)
		local p1 = v.p1

		-- 振り分け
		local sw = {
			help  = function()	se_ok() adv_manual() end,	-- マニュアル
			save  = function()	se_ok() adv_save() end,		-- セーブ
			load  = function()	se_ok() adv_load() 	end,	-- ロード
			favo  = function()	se_ok() adv_favo() end,		-- お気に入りボイス
			conf  = function()	se_ok() adv_config() end,	-- コンフィグ
			blog  = function()	se_ok() adv_backlog() end,	-- バックログ

			qsave = function()	adv_qsave() end,			-- クイックセーブ
			qload = function()	adv_qload() end,			-- クイックロード
			title = function()	adv_title() end,			-- タイトルに戻る
			voice = function()	adv_replay() end,			-- ボイスリプレイ
			exit  = function()	adv_exit() end,				-- exit

--			tweet = function()	adv_tweet() end,			-- tweet
			tweet = function()	menu_callfunc("tweet") end,		-- tweet

			back = function()	menu_callfunc("selback") end,	-- 前の選択肢に戻る
			next = function()	menu_callfunc("selnext") end,	-- 次の選択肢に進む
			auto  = function()	menu_callfunc("auto") end,		-- auto
			skip  = function()	menu_callfunc("skip") end,		-- skip
			mwoff = function()	menu_callfunc("msgoff") end,	-- msgoff
		}

		-- switch文
		if sw[p1] then
			sesys_stop("pause")		-- SE一時停止
			scr.menu.bt = bt
			sw[p1]()
		else
			error_message(bt, "は登録されていないメニューボタンです")
		end
	end
end
----------------------------------------
function menu_over(e, p)
	local bt = p.name
	local v  = getBtnInfo(bt)
	local z  = getBtnInfo("help")
	if v.p1 then
		local y = z.ch * v.p1
		tag{"lyprop", id=(z.idx), visible="1"}
		tag{"lyprop", id=(z.idx), clip=(z.cx..","..y..","..z.cw..","..z.ch)}
	else
		tag{"lyprop", id=(z.idx), visible="0"}
	end
end
----------------------------------------
-- □マニュアル
----------------------------------------
function mnal_init()
--	se_ok()
	csvbtn3("mnal", "500", lang.ui_manual)
	uitrans()
end
----------------------------------------
function mnal_reset()
	se_cancel()
	delbtn('mnal')
end
----------------------------------------
function mnal_close()
	mnal_reset()
--	uitrans{ rule="rule8r" }
end
----------------------------------------
function manual_click()
	e:tag{"var", name="t.path", data=(get_uipath().."manual")}
	e:tag{"jump", file="system/ui.asb", label="manual_copyright"}
end
----------------------------------------
