----------------------------------------
-- steam / 未調整
----------------------------------------
steam = {}
----------------------------------------
-- アチーブメント登録
function tags.achievements(e, p)
	if not gscr.steam then gscr.steam = {} end
	local s  = gscr.steam
	local nm = p.name
	if nm and not s[nm] then
		local v  = csv.achievements
		local no = tn(v[nm])

		message("通知", nm, "をアンロックしました", no)

		steam.exec("unlock", nm)
--		gscr.steam[nm] = true
--		asyssave()
	end
	return 1
end
----------------------------------------
-- 
----------------------------------------
function steam_init()
	local r = getWindowsCrc(init.steam_exename, init.steam_exe_crc)
	local crc01 = string.lower(init.steam_crc_01)
	local crc02 = string.lower(init.steam_crc_02)
	tag{"var", system="file_crc", name="t.crc01", file=(init.steam_dll_01)}
	tag{"var", system="file_crc", name="t.crc02", file=(init.steam_dll_02)}
	if crc01 ~= e:var("t.crc01") then r = true end
	if crc02 ~= e:var("t.crc02") then r = true end
	if r then
		e:tag{"exit"}
	else
		local id = getTrial() and "steam_appidtrial" or "steam_appid"
		steam.exec("initialize", init[id])
	end
end
----------------------------------------
-- 実行
function steam.exec(nm, param, data)
	local p  = {"callnative", result="t.steam", module=(init.steam_dll_02), method=(nm)}
	local sw = {

		----------------------------------------
		-- 初期化
		initialize = function()
			p.param = "appid="..param.." waitrecv=1"
			estag("init")
			estag(p)
			estag{"steam_check", nm}
			estag{"wait", time="1000"}
			estag()
		end,

		----------------------------------------
		-- setstatint
		setstatint = function()
			p.param = "name="..param..",data="..data
			eqtag(p)
			eqtag{"calllua", ["function"]="steam_check", com=(nm)}
		end,

		----------------------------------------
		-- achievements unlock
		unlock = function()
			p.method = "getstatint"
			p.param  = param
			eqtag(p)
			eqtag{"calllua", ["function"]="steam.unlockcheck", com=(nm), nm=(param)}
		end,
	}
	if sw[nm] then
		sw[nm]()
	else
		p.param = param or ""
		eqtag(p)
		eqtag{"calllua", ["function"]="steam_check", com=(nm)}
	end
end
----------------------------------------
function steam_check(cm)
	local s  = e:var("t.steam")
	local sw = {
--		[0] = "エラーなし",
--		[1] = "処理待ちを行う必要はない",

		-- エラー
		["8"]  = "CODE 00008 : Please login",							-- エラーです
		["9"]  = "CODE 00009 : Invalid parameter",						-- パラメータが無効です
		["10"] = "CODE 00010 : Invalid processing",						-- 処理が実装されていませんでした
		["11"] = "CODE 00011 : Data not found",							-- 指定した名前を持つデータは存在しませんでした
		["12"] = "CODE 00012 : Already initialized",					-- すでに初期化済みです
		["13"] = "CODE 00013 : Please launch the Steam application",	-- steamが起動していないため初期化できませんでした
		["14"] = "CODE 00014 : Incorrect application ID",				-- アプリケーションIDが正しくありません
		["15"] = "CODE 00015 : Initialization failure", 				-- ログインしていないか購入状態ではないため初期化できませんでした",
	}

	-- 初期化時の処理
	local er = sw[s]
	if cm == "initialize" then
		if not er then
			steam.initialize = true		-- 初期化完了
			steam.achievements()		-- アチーブメント開放チェック
			
			-- Deckの強制fullscreen
			if steam.is_running_on_deck() then
				conf.window = 1
				fullscreen_on()
			end
			
			eqtag{"reset"}
		else
			if debug_flag and (s == "8" or s == "13" or s == "15") then
				e:debug{ data=(er), raw=true, level=2 }
			else
				tag_dialog({ title="Steam Error", message=(er) }, "exit")
			end
		end

	-- 空白が返ってきた
	elseif s == "" then
		message("エラー", "Steamとの通信に失敗しました")

	-- その他処理
	else
--		message("エラー", s)
	end
end
----------------------------------------
-- steam解放処理
function steam.exit()
	if steam.initialize then
		message("通知", "steamを開放しました")
		tag{"callnative", result="t.steam", module=(steam.dll), method="release", param=""}
	end
end
----------------------------------------
-- unlock確認
function steam.unlockcheck(e, p)
	if not gscr.steam then gscr.steam = {} end
	local s  = e:var("t.steam")
	local cm = p.com
	local nm = p.nm
	local ck = gscr.steam[nm]
	if s == "err" then
		message("通知", nm, "のunlockに失敗しました")
	else	-- if not ck then
		message("通知", nm, "をunlockします")
		steam.exec("setstatint", nm, 1)
		steam.exec("storestats", "iswait=0")
		steam.atsave(nm)
	end
end
----------------------------------------
-- 保存
function steam.atsave(nm)
	if not gscr.steam then gscr.steam = {} end
	local p = gscr.steam
	local r = p[nm] and nil or true
	gscr.steam[nm] = 1
	steam.allclear()
	if r then syssave() end
end
----------------------------------------
-- 全開放チェック
function steam.allclear()
	local s = gscr.steam or {}
	local m = steam_initflag
	local n = steam.clear
	if m and n then
		local c = 0
		for k, v in pairs(s) do
			if v == 1 then c = c + 1 end
		end

		-- 開放
		if c == m then
			steam.exec("unlock", n)
		end
	end
end
----------------------------------------
-- 全開放仕込み
function steam.achievements()
	local p  = csv.achievements
	local cl = steam.clear
	for k, v in pairs(p) do
		if cl ~= k then
			tag{"callnative", result="t.steam", module=(steam.dll), method="getstatint", param=(k)}
			local no = e:var("t.steam")
			if no and no == "1" then
				gscr.steam[k] = 1
			end
		end
	end
	steam.allclear()
end
----------------------------------------
--
----------------------------------------
-- Steam Deckで起動しているかどうかの確認
-- 戻り値 : (boolean) deckで起動しているならtrue
function steam.is_running_on_deck()
	if game.os ~= "windows" then
		return false
	end

	tag{"callnative", result="t.steam", module=(init.steam_dll_02), method="is_running_on_deck", param=(k)}
	local no = e:var("t.steam")

	return no ~= "0"
end
----------------------------------------
-- Steam Deckでのムービー差し替え
-- file : 非Deck版で再生するムービーのファイル名
-- 戻り値 : 再生すべきムービーのファイル名。DeckであればDeck用のファイルパスに差し替える。
function steam.deck_movie_file_name(file)
	if steam.is_running_on_deck() then
		return "sd/"..file
	else
		return file
	end
end
