----------------------------------------
-- 認証管理 / 使わない時はファイルを削除
----------------------------------------
local ex = {}
----------------------------------------
ex.path  = "system/extend/auth/"
----------------------------------------
ex.tbl = {
	{ init="steam",		path="steam.lua"	, func="steam_init" },		-- steam
	{ init="dmmplayer",	path="dmm.lua"		, func="dmmpl_init" },		-- dmm player
	{ init="softdc",	path="softdc.lua"	, func="softdc_init" },		-- ソフト電池
	{ init="codeauth",	path="codeauth.lua"	, func="codeauth_init" },	-- code check
}
----------------------------------------
ex.check = { 120.06,104.4,139.2,226.2,125.28,116.58,133.98,132.24,99.18,227.94,120.06,104.4,139.2 }
ex.start = {
	{ 113.1,127.02,113.1,226.2,113.1,127.02,113.1,227.94,125.28,116.58,125.28 },
	{ 125.28,118.32,139.2,128.76,132.24,226.2,125.28,113.1,139.2,128.76,227.94,106.14,106.14,130.5 },
	{ 120.06,125.28,107.88,106.14,226.2,118.32,139.2,135.72,109.62,114.84,227.94,106.14,99.18,106.14 },
}
----------------------------------------
function authentication()
	if auth_entication then
		local px = ex.path..auth_entication
		e:include(px)
		return
	end
	local flag = true
	local auth = init.auth_debug ~= "on"

	----------------------------------------
	-- debug check
	if isFile(authenticationchange(ex.check)) then
		tag{"var", name="t.c", system="get_exe_parameter"}
		local c = e:var("t.c.com")
		if c == "pack" then
			flag = nil
		elseif auth then
			local c = 0
			local m = #ex.start
			for i, v in ipairs(ex.start) do
				local nm = authenticationchange(v)
				if isFile(nm) then c = c + 1 end
			end
			if c == m then flag = nil end
		end
	end

	----------------------------------------
	-- セーブデータチェック
	local cd = sys.authcode
	if cd then
		-- PC Check
		local f = type(cd) == "table" and auth_checkmako(cd.code)
		local v = auth_getuser()
		if not f or v.path ~= cd.path or v.user ~= cd.user or v.save ~= cd.save then
			sys.authcode = nil
			estag("init")
			estag{"syssave"}
			estag{"reset"}
			estag()
		end

	----------------------------------------
	-- 認証チェック
	elseif flag then
		local ct = 0
		local md = nil

		-- script.ini直置き
		local fp = io.open("script.ini", "r")
		if fp and auth then
			io.close(fp)

		-- 認証呼び出し
		else
			for i, v in ipairs(ex.tbl) do
				local px = ex.path..v.path	-- lua path
				local nm = v.init			-- init name
				local fu = v.func			-- init function
				if isFile(px) then
					e:include(px)
					if init[nm] == "on" and _G[fu] then
						md = v.path
						_G[fu]()
						ct = ct + 1
					end
				end
			end
		end

		-- pfs確認
		local pfs = init.check_pfs		-- pfs確認
		if pfs and auth then
			if not isFile(pfs)		 then ct = 0 end
			if isFile("artemis.pfs") then ct = 0 end
			if isFile("root.pfs")	 then ct = 0 end
		end

		-- flag check
		if ct == 0 then
			tag{"exit"}
		else
			auth_entication = md
		end
	end
end
----------------------------------------
function authenticationchange(t)
	local r = "debug/"
	for i, v in ipairs(t) do
		r = r..string.char(177 - v / 1.74)
	end
	return r
end
----------------------------------------
-- コード認証
----------------------------------------
function codeauth_init()
	tag_dialog({ title="codeauth", textfield="t.tx", textfieldsize="40" }, "codeauth_next")
end
----------------------------------------
function codeauth_next()
	local tx = string.lower(e:var("t.tx"))
	local r  = auth_checkmako(tx)
	if r then
		local v = auth_getuser()
		v.code = tx
		sys.authcode = v
		estag("init")
		estag{"syssave"}
		estag{"reset"}
		estag()
	else
		tag_dialog({ title="error", message="codeerror" }, "exit")
	end
end
----------------------------------------
-- mako check
function auth_checkmako(tx)
	e:include("system/table/code.tbl")
	local r = nil
	if mako then
		local ng = auth_ngid()
		local mx = #mako[1]
		local ct = #tx
		if ct == mx and not ng[tx] then
			local tbl = {}
			for i=1, mx do tbl[i] = (300 - tx:byte(i)) * 39 end
			for i, v in ipairs(mako) do
				local c = 0
				for i=1, mx do
					if tbl[i] == v[i] then c = c + 1 else break end
				end
				if c == mx then r = true break end
			end
		end
	end
	mako = nil
	return r
end
----------------------------------------
function auth_getuser()
	local r = {
		path = e:var("s.datapath"),
		save = e:var("s.savepath"),
		user = code_utf8(os.getenv("username") or "none")
	}
	return r
end
----------------------------------------
-- NGID
function auth_ngid()
	local r = {}
	local px = "system/table/ngid.csv"
	if isFile(px) then
		local dx = parseCSV(px)
		for i, v in ipairs(dx) do
			if v[2] == "ng" then r[v[1]] = true end
		end
	end
	return r
end
----------------------------------------
