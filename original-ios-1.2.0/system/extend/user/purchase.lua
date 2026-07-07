----------------------------------------
-- 課金管理
----------------------------------------
local ex = {}
----------------------------------------
ex.errortable = {
-- 1	購入完了
-- 2	購入済み
	["-1"]  = "purchase01",		-- iOSのユーザー設定において、課金不可に設定されている
	["-2"]  = "purchase02",		-- ネットワークに接続していない
	["-3"]  = "purchase03",		-- 既に課金処理が問い合わせ中 (エンジン側に不具合がなければ出ないはず)
	["-11"] = "purchase11",		-- このクライアントには実行できない
	["-12"] = "purchase12",		-- 購入がユーザーによってキャンセルされた
	["-13"] = "purchase13",		-- パラメータが不正
	["-14"] = "purchase14",		-- 支払いが許可されていない
	["-10"] = "purchase10",		-- 未知のエラー
}
----------------------------------------
-- purchaseタグ共通化
function ex.gettag(id, no)
	local p  = {"purchase", purchase=(no), varname="t.tmp"}
	local im = ""
	if game.os == "android" then
		p.key = init.google_licensekey	-- Google Play Developer Console で取得できるライセンスキー
		p.sku = id						-- 課金アイテムID
--		p.consume = "0"					-- 消費処理を行いません
	else
		p.productid = id				-- 課金アイテムID
--		p.restore = "0"					-- 復元処理を行いません
	end
	return p
end
----------------------------------------
-- 問い合わせ
function purchase_inquiry(productid)
	flg.purchase = nil
	local p = ex.gettag(productid, "0")	-- 確認
	eqtag(p)
	eqtag{"calllua", ["function"]="purchase_inquirynext", inquiry="1"}
end
----------------------------------------
-- 購入
function purchase_buy(productid)
	flg.purchase = nil
	local p = ex.gettag(productid, "1")	-- 購入
	eqtag(p)
	eqtag{"calllua", ["function"]="purchase_inquirynext"}
end
----------------------------------------
-- エラー確認
function purchase_inquirynext(e, p)
	local code = e:var("t.tmp")

	-- 課金済み
	if code == "1" or code == "2" then
		flg.purchase = true

	-- 未課金
	elseif code == "3" then
		flg.price = e:var("t.tmp.price")

	-- Windowsでは実行できない
	elseif game.trueos == "windows" then
		if debug_flag and not p.inquiry then
			ex.tag_dialog({ title="Windowsでは実行できません", message="購入処理を確認しますか？", varname="t.yesno" }, "purchase_inquirydebug")
		end

	-- エラー通知
	elseif ex.errortable[code] then
		ex.tag_dialog({ title="error", message=(ex.errortable[code]) })

	-- 不明なエラー
	else
		ex.tag_dialog({ title="error", message="purchase99", num=(code) })
	end
	tag{"var", system="delete", name="t.tmp"}
end
----------------------------------------
-- windows debug
function purchase_inquirydebug()
	local nm = "t.yesno"
	local yn = tn(e:var(nm))
	if yn == 1 then
		purchase_reseterror()
		flg.purchase = true
	end
	tag{"var", system="delete", name=(nm)}
end
----------------------------------------
-- restore
----------------------------------------
-- iOS / 復元処理
function purchase_restore()
	estag("init")
	estag{"purchase", restore="1", varname="t.tmp"}
	estag{"eqwait", 1000}
	estag{"purchase_restorecheck"}
	estag{"purchase_restoreexit"}
	estag()
end
----------------------------------------
-- 復元確認
function purchase_restorecheck()
	local code = e:var("t.tmp")
	local max  = tn(e:var("t.tmp.size"))
	if max < 0 then
		ex.tag_dialog({ title="notice", message="purchase91" })	-- 購入済みのアイテム情報が取得できませんでした。
	elseif max == 0 then
		ex.tag_dialog({ title="notice", message="purchase92" })	-- 購入済みのアイテムはありませんでした。
--	elseif code and ex.errortable[code] then
--		tag_dialog({ title="error", message=(ex.errortable[code]) })
	else
		gscr.shop = {}		-- 開放管理

		-- 並べ替え
		local z = {}
		for nm, v in pairs(csv.list_shop) do
			local pr = v[1]
			if pr == "none" then
				gscr.shop[nm] = true	-- productidが無いものは常に開放
			else
				z[pr] = nm				-- 有効なproductid
			end
		end

		-- 開放
		for i=0, max-1 do
			local pr = e:var("t.tmp."..i)
			local nm = z[pr]
			if nm then gscr.shop[nm] = true end
		end
--		tag_dialog({ title="復元完了", message=(max.."個のアイテムが復元されました。") })
		tag_dialog({ title="purchase93", message="purchase94", num=(max) })
	end
end
----------------------------------------
function purchase_restoreexit()
	tag{"var", name="t.tmp", system="delete"}
end
----------------------------------------
-- 
----------------------------------------
-- error message
function ex.tag_dialog(p, md)
	flg.purchaseerror = true	-- error flag
	tag_dialog(p, md)
end
----------------------------------------
function purchase_geterror()
	return flg.purchaseerror
end
----------------------------------------
function purchase_reseterror()
	flg.purchaseerror = nil
end
----------------------------------------
