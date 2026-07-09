----------------------------------------
-- 言語切替
----------------------------------------
local ex = {}
----------------------------------------
-- 起動時
function langsel_startup()
	local md = init.game_langselect or "first"
	local fl = md and (md == "first" and sys.langselect or md == "startup" and langselect)
	if md and not fl then
		ex.init()
		estag("init")
		estag{"uitrans", 1000}
		estag{"langsel_active"}
		estag{"eqwait"}
		estag("stop")
	end
end
----------------------------------------
-- ボタン描画
function ex.init()
	csvbtn3("lang", "600", lang.game_lang)
	setonpush_ui()
	flg.ui = {}
end
----------------------------------------
-- active処理
function langsel_active()
	if game.cs and bt then
		btn_active2(bt)
		flip()
	end
end
----------------------------------------
-- click処理
function langsel_click(e, p)
	local bt = p.btn
	local v  = getBtnInfo(bt)
	local p1 = v.p1			-- main/sub/ui/voice/sysvo/lvo
	local p2 = v.p2			-- ja/en/cn/tw
	set_language(p1, p2)
	set_langnum()

	se_ok()

	-- 保存
	local md = init.game_langselect
	if md == "first" then
		sys.langselect = true
	elseif md == "startup" then
		langselect = true
	end

	-- default
--	local nm = p1 == "main" and "language" or p1
--	if sys.def then sys.def = {} end
--	sys.def[nm] = p2

	-- ui消去
	delbtn('lang')

	estag("init")
	estag{"uitrans", 1000}
	estag{"syssave"}
	estag{"reloadSystemData"}
	estag{"reset"}			-- 起動時はリセットしてしまったほうが早い
	estag()
end
----------------------------------------
--[[
function langch_init()
	local bt = btn and btn.cursor
	if bt then btn_nonactive(bt) end

	-- 初期化
	flg.dlg2 = { bt=bt }
	if btn and btn.name then
		flg.dlg2.ui  = btn.name
		flg.dlg2.glp = btn.group
		flg.dlg2.btn = bt
	end

	-- ドラッグ禁止
	if flg.ui then
		sliderdrag_stat(0)
		flg.dlg2.ret = true		-- uiに戻す
	else
		flg.ui = {}
	end

	-- ボタン描画
	csvbtn3("dlg", "600", lang.ui_lang)		-- dialog

	-- 表示アニメ
	setonpush_ui()
--	tag{"lyprop", id="600.ba", visible="0"}
	tag{"lyprop", id="600.dl", visible="0"}
	estag("init")
	estag{"uitrans", { rule="rule_dialogon", fade="400" } }
	estag{"langch_active"}
	estag{"eqwait"}
	estag("stop")
end
----------------------------------------
function langch_active()
--	tag{"lyprop", id="600.ba", visible="1"}
	tag{"lyprop", id="600.dl", visible="1"}
	uitrans()
end
----------------------------------------
function langch_click(e, p)
	local bt = p.btn
	if bt then
		local v  = getBtnInfo(bt)
		local p1 = v.p1
		set_language("main", p1)

		-- 画面を閉じる
--		tag{"lyprop", id="600.ba", visible="0"}
		tag{"lyprop", id="600.dl", visible="0"}
		estag("init")
		estag{"uitrans"}
		estag{"lyprop", id="600", visible="0"}
		estag{"uitrans", { rule="rule_dialogoff", fade="400" } }
		estag{"asyssave"}
		estag{"langch_exit"}
		estag()
	end
end
----------------------------------------
function langch_exit()
	local v    = flg.dlg2
	delbtn('dlg')				-- ui消去
	e:tag{"lydel", id="600"}
	btn.name	= v.ui			-- 戻す
	btn.group	= v.glp
	btn.cursor	= v.btn
	flg.dlg2 = nil

	-- configに戻る
	if v.ret then
		sliderdrag_stat(1)		-- ドラッグ許可
		setonpush_ui()
		if game.cs and v.cancel and v.btn and v.ui ~= "adv" then
			btn_active2(v.btn)
		end

	-- その他
	else
		delonpush_ui()
		flg.ui = nil
	end

	-- 戻る
	estag("init")
	estag{"syssave"}
	estag{"reset"}			-- 起動時はリセットしてしまったほうが早い
	estag()
end
----------------------------------------
-- tag
tags.langselect = function()
	local r = getOSMode()
	local n = sys.langselect
	if r.steam and not n then
		sys.langselect = true
		langch_init()
	end
	return 1
end
----------------------------------------
]]
