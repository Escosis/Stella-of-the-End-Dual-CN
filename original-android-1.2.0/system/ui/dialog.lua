----------------------------------------
-- 画像ダイアログ
----------------------------------------
local ex = {}
----------------------------------------
-- message.iptを検索するファイル
ex.mesipt = {
	"dialog.ipt",
	"dlgmes.ipt",
}
----------------------------------------
ex.okbutton = {
	oktweet	= true,
	ngtweet	= true,
}
----------------------------------------
function dialog(name)
	fn.push("dlg", {
		{ scetweendel },
		{ dialog_main, name },
		{ dialog_exit, name },
	})
end
----------------------------------------
-- dialogを抜けたあとに実行する
function dialog_exit(name)
	local r = fn.get()
	if r == 1 then
		local sw = {
			-- qsave
			qsave = function()
				if flg.suspend then	sv.suspend()
				else				sv.quicksave() end
			end,

			qload = function() sv.quickload() end,	-- qload
			save  = function() sv.saveclick() end,	-- save
			save2 = function() sv.saveclick() end,	-- save上書き
			load  = function() sv.loadclick() end,	-- load
			cont  = function() title_load() end,	-- cont
			favo  = function() favoclick() end,		-- お気に入りボイス
			favo2 = function() favoclick() end,		-- お気に入りボイス上書き
			fdel  = function() favodelete() end,	-- お気に入りボイス削除

			reset = function() config_resetview() end,		-- config reset
			pgreset = function() config_pgdefview() end,	-- config page reset

			title = function() sv.go_title() end,	-- title
			exit  = function() sv.go_exit() end,	-- game exit
			scene = function() sv.go_title() end,	-- scene
			jump  = function() goBacklogJumpTo() end,	-- backlog jump

			back  = function() goBackSelect() end,	-- 前の選択肢に戻る
			next  = function() goNextSelect() end,	-- 次の選択肢に進む

			flow  = function() flow_script() end,	-- フローチャート確認
			web   = function() goWebAccess() end,	-- ブラウザを開く確認

			del   = function() sv.delete() end,		-- save data削除
			sus   = function() sv.suspend() end,	-- suspend

			-- tweet
			tweet = function()
				if tweet then
					tweet.start()
				else
					error_message("tweet機能が有効になっていません")
				end
			end,

			-- OKボタン
			oksus = function() load_suspendcheck2() end,
		}
		if sw[name] then
			message("通知", name, "を呼び出します")
			sw[name]()
		end
	else
		flg.savenum = nil
		reload_ui()
	end
end
----------------------------------------
-- dialog / 新ルーチン
function dialog_main(name)
	local bt = flg.btnactive or btn.cursor
	if bt then btn_nonactive(bt) end
	flg.btnactive = nil

	-- onになっていたらダイアログを表示せずに抜ける
	local dlg = get_dlgparam(name)
	if dlg == 1 then
--		se_ok()
		message("通知", "dialogで確認をしない設定です", name)
		return 1	-- yesの戻り値
	end

	message("通知", "dialogを開きました", name)

	-- 初期化
	sys.dlg = { dummy=dlg }
	flg.dlg = { name=name }
	if btn and btn.name then
		flg.dlg.ui  = btn.name
		flg.dlg.glp = btn.group
		flg.dlg.btn = bt
	end

	-- 表示
	dialog_view(name)

	-- 表示アニメ
	estag("init")
	estag{"uiopenanime", "dialog"}
	estag{"yesno_active"}
	estag{"eqwait"}
	estag("stop")
end
----------------------------------------
-- dialog / 表示
function dialog_view(name)
	-- ドラッグ禁止
	if flg.ui then sliderdrag_stat(0) end

	-- 音声を停止する
	if not flg.ui then sesys_stop("pause") end

	-- sys voice
	local s = csv.sysse.sysvo
	if name and s[name] then sysvo(name) end

	-- 
	local hd = "dlg"
	local id = "dlgbaseid"
	local md = "ui_yesno"
	if name == "gameend" then
		hd = "dlg2"
		id = "dlgwin_id"
		md = "ui_gameend"
	end
	local id = init[id] or "600"

	-- ボタン描画
	csvbtn3(hd, (id), lang[md])	-- dialog
	tag{"lyprop", id=(id), anchorx=(game.centerx), anchory=(game.centery)}

	-- text
	yesno_text(name, id)

	-- okボタン処理
	if name:find("ex[0-9][0-9]") or ex.okbutton[name] then
		setBtnStat('bt_yes', 'c')
		setBtnStat('bt_no', 'c')
		if checkBtnExist("bt_check") then tag{"lyprop", id=(getBtnID('bt_check')), visible="0"} end
		if checkBtnExist("bt_sus")   then setBtnStat('bt_sus', 'c') end

	-- suspend
	elseif name == "qsave" and checkBtnExist("bt_sus") then
		local y  = getBtnInfo("bt_yes")
		local n  = getBtnInfo("bt_no")
		local v  = getBtnInfo("bt_sus")
		local p1 = tn(v.p1) or 100
		tag{"lyprop", id=(y.idx), left=(y.x - p1)}
		tag{"lyprop", id=(n.idx), left=(n.x + p1)}

	-- ボタン
	else
		-- defaultは意味が無いのでcheckboxなし
		if name == "reset" and checkBtnExist("bt_check") and init.game_dialogreset == "hide" then
			setBtnStat('bt_check', 'c')
			tag{"lyprop", id=(getBtnID('bt_check')), visible="0"}
		end
		if checkBtnExist("bt_ok")  then setBtnStat('bt_ok', 'c') end
		if checkBtnExist("bt_sus") then setBtnStat('bt_sus', 'c') end
	end
end
----------------------------------------
-- yesをアクティブにする
function yesno_active()
	local time = yesno_fadetime()
	local name = conf.dialogact == 1 and "bt_no" or "bt_yes"
	if game.os == "windows" and conf.mouse == 1 then
		mouse_autocursor(name, time)
	elseif game.cs then
		estag("init")
		estag{"eqwait", time}
		estag{"btn_active2", name}
		estag{"flip"}
		estag()
--	else
--		eqwait(time)
	end
	eqtag{"lytweendel", id=(id)}
end
----------------------------------------
-- dialog fade time
function yesno_fadetime()
	return init.dlg_fade or init.ui_fade
end
----------------------------------------
-- dialog checkbox
function yesno_checkbox(e, p)
	if btn.cursor == "bt_check" then btn_change() end
end
----------------------------------------
-- dialog click
function yesno_click(e, p)
	local ret = 0
	local bt = btn.cursor
	if not bt then

	elseif bt == "bt_check" then
		yesno_checkbox(e, p)
	else
		if bt == "bt_yes" or bt == "bt_sus" then
			local tb = { exit=1, load=1, qload=1, favo=1, favo2=1 }
			local nm = flg.dlg.name
			if nm == "reset" and init.game_confdefault == "on" or nm ~= "reset" then se_yes() end
			if bt == "bt_sus" then flg.suspend = true end
			if not tb[nm] then sysvo("dlgyes") end

			-- 状態保存
			local a = sys.dlg.dummy
			local n = flg.dlg.name
			set_dlgparam(n, a)
			if n == "reset" and a == 1 then sys.dlgreset = true end	-- config reset
			asyssave()
			ret = 1

		elseif bt == "bt_no" then
			se_no()
			sysvo("dlgno")
			flg.dlg.cancel = true

		elseif bt == "bt_ok" then
			se_ok()
			ret = 1		-- 事後処理を呼べるようにする
		end
		fn.set(ret)
		yesno_exit()
	end
end
----------------------------------------
-- dialog escape
function yesno_esc(e, p)
	se_no()
	sysvo("dlgno")
	flg.dlg.cancel = true
--	if flg.dlg.name == 'qsave' then qsaveend(true) end
	fn.set(0)
	yesno_exit()
end
----------------------------------------
-- dialogを抜ける
function yesno_exit()
	ReturnStack()	-- 空のスタックを削除
--	message("通知", "dialogを閉じました")

	-- 画面を閉じる
--	tag{"var", name="t.lua", data="dialog_return"}
--	tag{"jump", file="system/ui.asb", label="return_ui"}
	uicloseanime("dialog")
end
----------------------------------------
-- dialogを抜ける
function dialog_return()
	local dlgp = flg.dlg
	local name = dlgp.name
	local id = init.dlgbaseid
	yesno_text(nil, id)			-- 文字消去
	delbtn('dlg')				-- ui消去
	e:tag{"lydel", id=(id)}
	btn.name	= flg.dlg.ui	-- 戻す
	btn.group	= flg.dlg.glp
	btn.cursor	= flg.dlg.btn
	flg.dlg = nil
	sys.dlg = nil
	delonpush_ui()

	-- checkbox check
	if name == "load" or name == "qload" then
		if get_dlgparam(name) == 1 then
			temp_dialog = name
		end
	end

	-- ui
	if flg.ui then
		sliderdrag_stat(1)		-- ドラッグ許可
		setonpush_ui()
		if game.cs and dlgp.cancel and dlgp.btn and dlgp.ui ~= "adv" then
			btn_active2(dlgp.btn)
			flip()
		end

	-- 選択肢
	elseif scr.select then
		sv.delpoint()
		sesys_resume()			-- se再開
		setonpush_ui()
	else
		sv.delpoint()
		sesys_resume()			-- se再開
		autoskip_init()
	end

	-- 戻る
	tag{"return"}
	tag{"jump", file="system/ui.asb", label="return"}
end
----------------------------------------
-- 文字
function yesno_text(name, id)

	-- ipt検索
	ipt = nil
	local px = get_uipath().."mw/"
	for i, v in ipairs(ex.mesipt) do
		local fl = px..v
		if isFile(fl) then
			e:include(fl)
			if ipt then break end
		end
	end
	if name and ipt and ipt[name] then
		tag{"lyprop", id=(getBtnID('message')), clip=(ipt[name])}
		return
	end

	-- csvから読み込む
	local v = getLangHelp("dlgmes")
	if v then
		local ix = id..".dl.text"
		if name then
			local tx = v[name] or ""
			ui_message(ix, { "dialog", text=(tx) })
		else
			ui_message(ix)
		end
	end
end
----------------------------------------
-- game end
----------------------------------------
function yesno_gameend()
	local nm = "gameend"
	local bt = flg.btnactive or btn.cursor
	if bt then btn_nonactive(bt) end
	flg.btnactive = nil

	flg.dlg2 = {}

	if btn and btn.name then
		flg.dlg2.ui  = btn.name
		flg.dlg2.glp = btn.group
		flg.dlg2.btn = bt
	end

	-- 設置
	dialog_view(nm)

	-- 表示
	tag{"return"}
	estag("init")
	estag{"uiopenanime", nm}
	estag{"yesno_active"}
	estag{"eqwait"}
	estag("stop")
end
----------------------------------------
function yesno_exclick(e, p)
	local nm = p.name
	local bt = p.btn
	local fl, r
	if nm == "CLICK" and bt or nm == "EXIT" then fl = true end
	if nm == "CLICK" and bt == "bt_yes" then r = true end
	flg.dlg2.click = r

	-- 閉じる
	if fl then
		tag{"return"}
		tag{"return"}
		uicloseanime("gameend")
	end
end
----------------------------------------
function yesno_exclickexit()
	local z    = flg.dlg2
	local name = z.name
	yesno_text(nil, init.dlgwin_id)		-- 文字消去
	delbtn('dlg2')						-- ui消去
	btn.name	= z.ui					-- 戻す
	btn.group	= z.glp
	btn.cursor	= z.btn
	flg.dlg2 = nil
	delonpush_ui()

	-- 終了
	if z.click then
		sv.go_exit()

	-- dialogに戻る
	elseif flg.dlg then
		btn.name	= "dlg"
		btn.group	= nil
		btn.cursor	= nil
		setonpush_ui()
		button_autoactive()

	-- UIに戻る
	elseif flg.ui then
		sliderdrag_stat(1)		-- ドラッグ許可
		setonpush_ui()
		button_autoactive()

	-- ゲーム画面に戻る
	else
		sesys_resume()			-- se再開
		if scr.select then setonpush_ui() else autoskip_init() end
	end
end
----------------------------------------
