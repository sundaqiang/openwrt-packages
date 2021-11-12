module("luci.controller.nginx-manager", package.seeall)

function index()
    file=nixio.fs.readfile("/etc/init.d/nginx")
    local isok
    if file:find('CONF=""') ~= nil then
    	file=file:gsub('CONF=""', 'CONF="/etc/nginx/nginx.conf"')
    	file=file:gsub("%[[%p%s]+z[%p%s]+CONF[%p%s]+return[%p%s]+already[%p%s]+called%p","#%1")
    	nixio.fs.writefile("/etc/init.d/nginx", file)
    	isok=1
	end
    if not nixio.fs.access("/etc/nginx/nginx.conf") then
        nixio.fs.copyr("/var/lib/nginx/uci.conf", "/etc/nginx/nginx.conf")
        isok=1
    end
    if isok then
        luci.sys.call("/etc/init.d/nginx restart")
    end
    file=nixio.fs.readfile("/etc/uwsgi/vassals/luci-webui.ini")
    if file:match("limit%pas[%p%s]+(%d+)") ~= "5000" then
    	file=file:gsub("limit%pas[%p%s]+(%d+)","limit-as = 5000")
    	nixio.fs.writefile("/etc/uwsgi/vassals/luci-webui.ini", file)
    	luci.sys.call("/etc/init.d/uwsgi restart")
    end
    nixio.fs.writefile("/etc/config/nginx-manager", "")
    x = luci.model.uci.cursor()
    x:set("nginx-manager", "main", "nginx")
    x:set("nginx-manager", "main", "name", "main")
    x:set("nginx-manager", "main", "filepath", "/etc/nginx/nginx.conf")
    for path in nixio.fs.dir("/etc/nginx/conf.d") do
        if path:find(".conf$") ~= nil then
            name = path:gsub(".conf", "")
            x:set("nginx-manager", name, "nginx")
            x:set("nginx-manager", name, "name", name)
            x:set("nginx-manager", name, "filepath", "/etc/nginx/conf.d/" .. path)
    	end
    end
    x:commit("nginx-manager")
    entry({"admin", "services", "nginx-manager"}, cbi("nginx-manager"), _("Nginx Manager"), 95).dependent = true
end