----------------------------------------
-- 追加 / shop
----------------------------------------
local ex = {}
----------------------------------------
ex.funcname = "user_shopimage"		-- 待機画像を表示する関数
----------------------------------------
-- 課金情報確認
function netshop_check(p)
	flg.purchase = nil		-- 課金フラグを倒しておく
	local nm = p.name
	local lb = p.label or "quick"
	local z  = csv.list_shop or {}
	local pr = nm and z[nm] and z[nm][1]
	if pr and lb and game.sp then
		if not gscr.shop then gscr.shop = {} end		-- 開放管理
		local oo = game.os
		local ok = gscr.shop[nm]
		local fl = true

		-- iosはフラグチェックのみ
		if ok and oo == "ios" then
			fl = nil

		-- androidはOSチェックする
		elseif ok and oo == "android" then
			if init.purchase_android == "on" then
				local osname = e:var("s.androidmodel")		-- 実行中のAndroidの機種名
				local os_ver = e:var("s.androidversion")	-- 実行中のAndroidのバージョン
				local saveos = gscr.shop.osname
				local sv_ver = gscr.shop.os_ver
				if osname == saveos and os_ver == sv_ver then
					fl = nil
				end
			else
				fl = nil
			end
		end

		-- ネットを見に行く
		if fl then netshop_init(nm, pr, lb) end

	-- error
	elseif not lb then
		error_message("labelが指定されてません")
	elseif game.sp then
		error_message("nameが指定されていないか間違っています")
	end
end
----------------------------------------
-- ネットの情報を参照
function netshop_init(nm, pr, lb)
	local z = { nm, pr, lb }
	local fc = ex.funcname			-- 待機画像

	-- 購入TAG
--[[
	estag("init")
	if _G[fc] then estag{fc} end	-- image
	estag{"purchase_inquiry", pr}	-- 問い合わせ
	estag{"netshop_tag", pr}		-- 購入TAG
	estag{"netshop_exit", z}		-- 終了処理
	estag{"netshop_save"}			-- syssave実行
	estag()
]]

	-- 購入UI
	estag("init")
	if _G[fc] then estag{fc} end	-- image
	estag{"purchase_inquiry", pr}	-- 問い合わせ
	estag{"netshop_ui", z}			-- 購入UI
	estag()
end
----------------------------------------
-- tag処理
----------------------------------------
-- 購入画面を出さない / タグ処理のみ
function netshop_tag(pr)
	if not flg.purchase then
		purchase_buy(pr)
	end
end
----------------------------------------
-- 終了処理
function netshop_exit(z)
	local nm = z[1]
	local pr = z[2]
	local lb = z[3]

	-- 購入済み
	if flg.purchase then
		netshop_buycheck(nm)

	-- 巻き戻す
	elseif lb == "quick" then
		local no = #log.stack
		quickjump(no, true)

	-- 巻き戻す
	else
		table.remove(log.stack, #log.stack)
		gotoScript{ label=(lb) }
	end
end
----------------------------------------
-- UI処理
----------------------------------------
-- 購入画面を出す
function netshop_ui(z)
	local nm = z[1]
	if not flg.purchase then
		local t  = csv.list_shop[nm]
		local tx = t[2]
		local tl = t[3]
		local yn = NumToPrice(flg.price or t[4] or 9999999)

		flg.ui = { shop=(z) }
		csvbtn3("user", "500", lang.game_shop)
		ui_message('500.tx.1', {"purchase_title", text=(tl)})
		ui_message('500.tx.2', {"purchase_text" , text=(tx)})
		ui_message('500.tx.3', {"purchase_price", text=(yn)})
		if game.os ~= "ios" and checkBtnExist("restore") then tag{"lyprop", id=(getBtnID("restore")), visible="0"} end
		estag("init")
		estag{"uiopenanime", "shop"}
		estag{"eqwait"}
		estag("stop")

	-- タイトル処理
	elseif getTitle() then
		if not gscr.shop then gscr.shop = {} end		-- 開放管理
		netshop_buycheck(nm)
		title_init()
	end
end
----------------------------------------
-- click処理
function netshop_click(e, p)
	local v  = getBtnInfo(p.bt or p.btn)
	local p1 = v.p1
	local sw = {
		exit	= function() se_cancel() netshop_uiexit() end,		-- 抜ける
		buy		= function() se_ok()	 netshop_uibuy() end,		-- 購入
		restore = function() se_ok()	 netshop_restore() end,		-- 復帰
	}
	if sw[p1] then sw[p1]() end
end
----------------------------------------
-- UI抜ける
function netshop_uiexit()
	local t  = flg.ui.shop
	local nm = t[1]
	local lb = not flg.purchase and t[3]
	netshop_buycheck(nm)

	-- error
	if flg.purchaseerror then
		flg.purchaseerror = nil

	else
		estag("init")
		estag{"delbtn", "user"}			-- UI削除
		estag{"uicloseanime", "shop"}
		estag{"netshop_save"}			-- system save
		estag{"netshop_uiexitjump", lb}
		estag()
	end
end
----------------------------------------
-- UI抜ける / labeljump
function netshop_uiexitjump(lb)
	ResetStack()
	flg.ui = nil

	-- タイトル画面に戻る
	if getTitle() then
		title_init()

	-- 本編中
	else
		-- ボタン設置
		init_adv_btn()
		flip()

		-- 購入できていなければlabelに飛ぶ
		if lb then
			gotoScript{ label=(lb) }
		end
	end
end
----------------------------------------
-- UI購入処理
function netshop_uibuy()
	if not flg.purchase then
		local t  = flg.ui.shop
		local pr = t[2]

		estag("init")
		estag{"purchase_buy", pr}	-- 購入
		estag{"eqwait"}				-- waitを入れておく
		estag{"netshop_uiexit"}		-- 抜ける
		estag()
	end
end
----------------------------------------
-- 復帰処理
function netshop_restore()
	estag("init")
	estag{"purchase_restore"}
	estag{"netshop_restorenext"}
	estag()
end
----------------------------------------
function netshop_restorenext()
	local t  = flg.ui.shop
	local nm = t[1]
	flg.purchase = gscr.shop[nm]
	netshop_uiexit()
end
----------------------------------------
-- 共通
----------------------------------------
-- 課金情報の保存
function netshop_buycheck(nm)
	if flg.purchase then
		if not gscr.shop[nm] then
			gscr.shop[nm] = true

			-- androidは機種を保存
			if game.os == "android" and init.purchase_android == "on" then
				gscr.shop.osname = e:var("s.androidmodel")		-- 実行中のAndroidの機種名
				gscr.shop.os_ver = e:var("s.androidversion")	-- 実行中のAndroidのバージョン
			end
		end
	end
end
----------------------------------------
-- セーブデータに保存
function netshop_save()
	if flg.purchase then asyssave() end
	flg.purchase = nil
end
----------------------------------------
