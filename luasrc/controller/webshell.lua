module("luci.controller.webshell", package.seeall)

function index()
	page = entry({"admin", "services", "webshell"}, template("webshell"), _("Web Shell"), 100)
	page.i18n="webshell"
	page.leaf = true

	entry({"admin", "services", "cmd_run"}, call("cmd_run"), nil)
end

function cmd_run()
	local cmd = luci.http.formvalue("cmd")
	local path = luci.http.formvalue("path")

	local re = ""
	if cmd ~= "" then re = luci.sys.exec("cd "..path.." && "..cmd .. " 2>&1") end

	local pwdcmd = "cd "..path.." && pwd "
	if cmd == "cd" or string.sub(cmd,1,3) == "cd " then
		pwdcmd = "cd "..path.." && " ..cmd.." && pwd "
	end

	local newpath = luci.sys.exec(pwdcmd)
	if newpath == "" then newpath = path end

	local ls = luci.sys.exec("ls " .. newpath)
	local host = luci.sys.exec("uname -n")
	local user = luci.sys.user.getuser(nixio.getuid())['name']

	local rv = { }; rv['res'] = re; rv['path'] = newpath; rv['ls'] = ls; rv['host'] = host; rv['user'] = user

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function cmd_upload()
    local filecontent = luci.http.formvalue("upload-file")
    local filename = luci.http.formvalue("upload-filename")
    local uploaddir = luci.http.formvalue("upload-dir")
    local filepath = uploaddir..filename
    local url = luci.dispatcher.build_url('admin', 'system', 'filebrowser')

    local fp
    fp = io.open(filepath, "w")
    fp:write(filecontent)
    fp:close()
    luci.http.redirect(url..'?path='..uploaddir)

end
