module("luci.controller.webshell", package.seeall)

function index()
	page = entry({"admin", "services", "webshell"}, template("webshell"), _("Web Shell"), 100)
	page.i18n="webshell"
	page.leaf = true

	entry({"admin", "services", "cmd_run"}, call("cmd_run"), nil)
end

function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

function cmd_run()
	local re =""
	local path = luci.dispatcher.context.requestpath
	local rv   = { }
	local cmd = luci.http.formvalue("cmd")
	local path = luci.http.formvalue("path")
	local runcmd="cd "..path.."&&"..cmd


	local shellpipe = io.popen(runcmd.." 2>&1","rw")
	re = shellpipe:read("*a")
	shellpipe:close()
	if not re then
		re=""
	end

	local pwdcmd = "cd "..path.."&& pwd 2>&1"
	if string.starts(cmd,"cd") then
		pwdcmd = "cd "..path.."&&"..cmd.."&& pwd 2>&1"
	end
	local shellpipe = io.popen(pwdcmd,"rw")
	local newpath = shellpipe:read("*a")
	shellpipe:close()

	if not newpath then
		newpath=path
	end

	local pathcmd = io.popen("ls "..newpath.."2>&1","rw")
	local ls = pathcmd:read("*a")
	pathcmd:close()

	ls = string.gsub(ls, "\n", ",")
	re = string.gsub(re, "\n", "\r\n")

	rv[#rv+1]=re
	rv[#rv+1]=newpath
	rv[#rv+1]=ls



	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

	luci.http.status(404, "No such device")
end
