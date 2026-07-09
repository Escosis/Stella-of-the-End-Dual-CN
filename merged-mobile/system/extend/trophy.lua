----------------------------------------
-- CS専用 / Switchでも使用する
----------------------------------------
cs = {}
----------------------------------------
local ex = {}
----------------------------------------
-- トロフィータグ
function tags.trophy(e, p)		if game.ps then ex.setTrophy(p["0"] or p.name) end	return 1 end
function tags.setTrophy(e, p)	if game.ps then ex.setTrophy(p["0"] or p.name) end	return 1 end
function tags.getTrophy(e, p)	if game.ps then ex.getTrophy(p) end					return 1 end
function tags.checktrophy(e, p)	if game.ps then ex.checktrophy(p) end				return 1 end
----------------------------------------
-- Switch
----------------------------------------
function cs.init()
	if game.truecs then
		cs.watermark("init")
	end
end
----------------------------------------
-- e:callOeAPI{type = 0}			スクリーンショット許可
-- e:callOeAPI{type = 1}			スクリーンショット禁止
-- e:callOeAPI{type = 2}			ムービーキャプチャ許可
-- e:callOeAPI{type = 3}			ムービーキャプチャ禁止
-- e:callOeAPI{type = 4, b = true}	ウォーターマーク許可
-- e:callOeAPI{type = 4, b = false}	ウォーターマーク禁止
function cs.watermark(mode)
	----------------------------------------
	-- 通知
	local func = function(nm)
		if init.cs_imageshoot == "on" and not flg.ui and not flg.dlg and not flg.dlg2 then
			notify(nm)
		end
	end

	----------------------------------------
	local sw = {

	-- 初期値
	init = function()
		-- switch
		if game.sw then
			local cr = isFile("copyright.png")
			e:callOeAPI{ type=0 }
			e:callOeAPI{ type=2 }
			e:callOeAPI{ type=4, b=(cr) }
			cs.copyright = cr

		-- PS4
		elseif game.ps then
		end
	end,

	-- on
	on = function()
		-- switch
		if game.sw then
			e:callOeAPI{ type=0 }
			e:callOeAPI{ type=2 }
			e:callOeAPI{ type=4, b=(cs.copyright) }
			func("shoot_on")

		-- PS4
		elseif game.ps then
		end
	end,

	-- off
	off = function()
		-- switch
		if game.sw then
			e:callOeAPI{ type=1 }
			e:callOeAPI{ type=3 }
			e:callOeAPI{ type=4, b=false }
			func("shoot_off")

		-- PS4
		elseif game.ps then
		end
	end,
	}
	if sw[mode] then sw[mode]() end
end
----------------------------------------
-- PS
----------------------------------------
-- トロフィー開放
function ex.setTrophy(name)
	if game.ps and not getTrial() then
		if not gscr.trophy then gscr.trophy = {} end
		local v  = csv.trophy[name]
		local no = v and v[1]
		if not no then
			error_message(name.."は不明なトロフィーです")
		elseif gscr.trophy[no] then
			message("通知", name, "は登録済みのトロフィーです")
			eqtag{"trophy", id=(no)}
		else
			message("通知", "Trophy:", name, "を開放しました")
			eqtag{"trophy", id=(no)}
			gscr.trophy[no] = true
		end
	end
end
----------------------------------------
-- トロフィーチェック
function ex.checktrophy(p)
	if game.ps and not getTrial() then
		if not gscr.trophy then gscr.trophy = {} end
		local name = p["0"] or p.name
		local v    = csv.trophy[name]
		if gscr.trophy[name] then
			message("通知", name, "は登録済みです")
		elseif v then
			local nm = v[1]		-- 管理変数名
			local mx = v[2]		-- 最大数
			local tr = v[3]		-- トロフィー名
			local no = gscr.trophy[nm] or 0
			if no >= 0 then
				message("通知", "Trophy flag:", name, "を開放しました")
				gscr.trophy[name] = true
				no = no + 1
				if no == mx then
					ex.setTrophy(tr)
					no = -1
				end
				gscr.trophy[nm] = no
			end
		end
	end
end
----------------------------------------
-- トロフィー状態
function ex.getTrophy(e, p)
	local nm = p["0"] or p.name
	if nm then
		tag{"trophy", id="-1"}
		tag{"var", name="t.result", system="get_trophy_status", id=(nm)}
		local n = tn(e:var("t.result"))
		if n == -2 then
			error_message("トロフィーの取得に失敗しました:"..nm)
		elseif n == -1 then
			message("通知", nm, "は登録中です")
		else
			ex.checkTrophy()
		end
	end
end
----------------------------------------
