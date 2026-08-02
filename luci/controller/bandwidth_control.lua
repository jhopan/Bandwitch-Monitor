module("luci.controller.bandwidth_control",package.seeall)
local http=require "luci.http"
local sys=require "luci.sys"
local dsp=require "luci.dispatcher"

function index()
 entry({"admin","services","bandwidth-control"},cbi("bandwidth_control"),_("Bandwidth Control"),90).dependent=false
 entry({"admin","services","bandwidth-control","backup"},call("backup")).leaf=true
 entry({"admin","services","bandwidth-control","restore"},call("restore")).leaf=true
end
function backup()
 local p=io.popen("tar -C / -czf - etc/config/bandwidth-control etc/bandwidth-control 2>/dev/null")
 local data=p:read("*a"); p:close()
 http.header("Content-Disposition","attachment; filename=bandwidth-control-backup.tar.gz")
 http.prepare_content("application/gzip"); http.write(data)
end
function restore()
 local path="/tmp/bandwidth-control-restore.tar.gz"; local file
 http.setfilehandler(function(meta,chunk,eof)
  if not file and meta and meta.name=="archive" then file=io.open(path,"w") end
  if file and chunk then file:write(chunk) end
  if file and eof then file:close(); file=nil end
 end)
 http.formvalue("archive")
 local bad=sys.call("test -s "..path.."; tar tzf "..path.." | grep -Ev '^(etc/config/bandwidth-control|etc/bandwidth-control(/.*)?)$' >/dev/null")
 if bad==0 then
  sys.call("rm -f "..path)
  http.status(400,"Invalid backup"); http.write("Invalid backup archive"); return
 end
 if sys.call("tar xzf "..path.." -C / && /etc/init.d/bandwidth-control restart")~=0 then
  http.status(500,"Restore failed"); http.write("Restore failed"); return
 end
 sys.call("rm -f "..path)
 http.redirect(dsp.build_url("admin/services/bandwidth-control"))
end
function audit()
 return sys.exec("/usr/libexec/bandwidth-control/check audit 50 2>/dev/null")
end
