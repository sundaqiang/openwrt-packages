module("luci.controller.nginx-manager", package.seeall)

function index()
    nixio.fs.writefile("/etc/config/nginx-manager", "")
    x = luci.model.uci.cursor()
    x:set("nginx-manager", "main", "nginx")
    x:set("nginx-manager", "main", "name", "main")
    x:set("nginx-manager", "main", "filepath", "/etc/nginx/uci.conf")
    for path in nixio.fs.dir("/etc/nginx/conf.d") do
        if string.find(path,".conf$") ~= nil then
            name = string.gsub(path, ".conf", "")
            x:set("nginx-manager", name, "nginx")
            x:set("nginx-manager", name, "name", name)
            x:set("nginx-manager", name, "filepath", "/etc/nginx/conf.d/" .. path)
    	end
    end
    x:commit("nginx-manager")
    entry({"admin", "services", "nginx-manager"}, cbi("nginx-manager"), _("Nginx Manager"), 95).dependent = true
end
