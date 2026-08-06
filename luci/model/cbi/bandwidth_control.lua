local sys = require "luci.sys"
local util = require "luci.util"

local function split(s)
 local t={} for v in (s or ""):gmatch("[^|]+") do t[#t+1]=v end return t
end
local function usage(mac)
 local a=split(sys.exec("/usr/libexec/bandwidth-control/check usage "..util.shellquote(mac).." 2>/dev/null"):gsub("%s+$", ""))
 return tonumber(a[1]) or 0, tonumber(a[2]) or 0, tonumber(a[3]) or 0
end
local function state(mac)
 local a=split(sys.exec("/usr/libexec/bandwidth-control/check status "..util.shellquote(mac).." 2>/dev/null"):gsub("%s+$", ""))
 return a[1] or "allowed", a[2] or "", a[3] or ""
end
local function group_usage(macs)
 local args=""; for _,mac in ipairs(macs or {}) do args=args.." "..util.shellquote(mac) end
 local a=split(sys.exec("/usr/libexec/bandwidth-control/check group-usage"..args.." 2>/dev/null"):gsub("%s+$", ""))
 return tonumber(a[1]) or 0, tonumber(a[2]) or 0, tonumber(a[3]) or 0
end
local function quota_value(v)
 local raw=(v or "0"):gsub(",",".")
 return tonumber(raw) or 0
end
local function fmt(n)
 if n >= 1073741824 then return string.format("%.2f GB",n/1073741824) end
 if n >= 1048576 then return string.format("%.2f MB",n/1048576) end
 return string.format("%.0f KB",n/1024)
end
local function leases()
 local t={} for l in sys.exec("/usr/libexec/bandwidth-control/check leases 2>/dev/null"):gmatch("[^\r\n]+") do
  local mac,ip,host=l:match("^([^|]+)|([^|]+)|(.+)$"); if mac then t[mac]=string.format("%s — %s (%s)",mac:upper(),host,ip) end
 end return t
end
local function picker(o)
 o.datatype="macaddr"; for mac,label in pairs(leases()) do o:value(mac,label) end
end
local function unique_mac(cursor, section, value)
 local unique=true
 cursor:foreach("bandwidth-control", "device", function(s)
  if s[".name"] ~= section and (s.mac or ""):lower() == value:lower() then unique=false end
 end)
 return unique
end

local m=Map("bandwidth-control",translate("Bandwidth Control"),translate("Quota counts download + upload during current nlbwmon period. MAC is enforcement identity; static IP is optional."))
m:append(Template("bandwidth_control/styles"))
local main=m:section(TypedSection,"main",translate("Service and quota reset")); main.anonymous=true; main.addremove=false
main:option(Flag,"enabled",translate("Enable"))
local interval=main:option(Value,"interval",translate("Check interval (seconds)")); interval.datatype="uinteger"; interval.default=60
local reset=main:option(ListValue,"reset_day",translate("Monthly quota reset")); for i=1,28 do reset:value(tostring(i),translate("Day ")..i) end
reset.description=translate("Changes nlbwmon accounting period. Applies at next period; existing counters are retained.")

local dash=m:section(SimpleSection,translate("Dashboard"))
local total,blocked=0,0
m.uci:foreach("bandwidth-control", "device", function(s)
 total=total+1; local st=state(s.mac or ""); if st=="blocked" then blocked=blocked+1 end
end)
dash.description=string.format("%d configured device(s), %d blocked. Warning: yellow 80%%, red 95%%, blocked 100%%. Backup: <a href='%s'>download config and usage state</a>.",total,blocked,require("luci.dispatcher").build_url("admin/services/bandwidth-control/backup"))

local dev=m:section(TypedSection,"device",translate("Devices"),translate("Quota per device. Click Edit only when replacing the connected device.")); dev.anonymous=true; dev.addremove=true; dev.template="cbi/tblsection"
dev:option(Value,"name",translate("Name"))
local editmac=dev:option(Button,"begin_edit",translate("Edit")); editmac.inputtitle=translate("Edit MAC"); editmac.inputstyle="apply"; function editmac.write(self,s) self.map.uci:set("bandwidth-control",s,"edit_mode","1") end
local savedlease=dev:option(DummyValue,"saved_lease",translate("Current device"))
function savedlease.cfgvalue(self,s)
 local value=self.map.uci:get("bandwidth-control",s,"mac") or ""
 return leases()[value] or (value ~= "" and value:upper().." — offline" or translate("Not selected"))
end
local newmac=dev:option(ListValue,"new_mac",translate("Select replacement DHCP device")); picker(newmac); newmac.template="bandwidth_control/mac_edit"
newmac.description=translate("Visible only after Edit MAC. Save & Apply confirms the identity change.")
function newmac.write(self,s,value)
 if self.map.uci:get("bandwidth-control",s,"edit_mode") ~= "1" then return end
 if not unique_mac(self.map.uci,s,value) then self:add_error(s,translate("This MAC already belongs to another device.")); return end
 self.map.uci:set("bandwidth-control",s,"mac",value)
 self.map.uci:delete("bandwidth-control",s,"edit_mode")
end
function dev.create(self,section)
 local s=TypedSection.create(self,section)
 self.map.uci:set("bandwidth-control",s,"edit_mode","1")
 return s
end
local quota=dev:option(Value,"quota_gb",translate("Quota (GB)"))
function quota.validate(self,v) v=(v or ""):gsub(",", "."); if v:match("^%d+%.?%d*$") and tonumber(v)>0 then return v end; return nil, translate("Use a positive GB value, e.g. 0,1 or 0.5") end
local rolling=dev:option(ListValue,"rolling_days",translate("Per-device reset")); rolling:value("0",translate("Use monthly reset")); rolling:value("7",translate("Every 7 days")); rolling:value("30",translate("Every 30 days")); rolling.default="0"
dev:option(Flag,"enabled",translate("Enabled"))
local last=dev:option(DummyValue,"last",translate("Last seen")); function last.cfgvalue(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac") or ""; local b="/etc/bandwidth-control/"..mac:lower(); local f=io.open(b..".last_seen"); local t=f and f:read("*l") or "Never"; if f then f:close() end; return t end
local used=dev:option(DummyValue,"used",translate("Usage / quota")); function used.cfgvalue(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac") or ""; local _,_,n=usage(mac); local q=quota_value(self.map.uci:get("bandwidth-control",s,"quota_gb")); return string.format("%s / %s GB",fmt(n),q) end
local details=dev:option(DummyValue,"details",translate("Download / upload")); function details.cfgvalue(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac") or ""; local rx,tx=usage(mac); return fmt(rx).." / "..fmt(tx) end
local stat=dev:option(DummyValue,"status",translate("Status")); function stat.cfgvalue(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac") or ""; local a,b,c=state(mac); return a=="blocked" and ("Blocked: "..b.." "..c) or "Allowed" end
local block=dev:option(Button,"block",translate("Manual block")); block.inputtitle=translate("Block now"); block.inputstyle="remove"; function block.write(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac"); if mac then sys.call("/usr/libexec/bandwidth-control/check block "..util.shellquote(mac).." manual") end end
local un=dev:option(Button,"unblock",translate("Manual review")); un.inputtitle=translate("Unblock"); un.inputstyle="apply"; function un.write(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac"); if mac then sys.call("/usr/libexec/bandwidth-control/check unblock "..util.shellquote(mac)) end end
local clear=dev:option(Button,"reset",translate("Reset quota")); clear.inputtitle=translate("Reset now"); clear.inputstyle="apply"; function clear.write(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac"); if mac then sys.call("/usr/libexec/bandwidth-control/check reset "..util.shellquote(mac)) end end
local fixed=dev:option(Button,"static",translate("Static IP")); fixed.inputtitle=translate("Set static"); function fixed.write(self,s) local mac=self.map.uci:get("bandwidth-control",s,"mac"); if not mac then return end; for l in sys.exec("/usr/libexec/bandwidth-control/check leases"):gmatch("[^\r\n]+") do local lm,ip,host=l:match("^([^|]+)|([^|]+)|(.+)$"); if lm==mac then local id="bc_"..mac:gsub(":",""); sys.call("uci -q delete dhcp."..id); sys.call("uci set dhcp."..id.."=host"); sys.call("uci set dhcp."..id..".mac="..util.shellquote(mac)); sys.call("uci set dhcp."..id..".ip="..util.shellquote(ip)); sys.call("uci set dhcp."..id..".name="..util.shellquote(host)); sys.call("uci commit dhcp; /etc/init.d/dnsmasq reload"); return end end end

local manage=m:section(SimpleSection,translate("Audit and backup")); manage.template="bandwidth_control/manage"
local group=m:section(TypedSection,"group",translate("Groups"),translate("All selected devices share one quota.")); group.anonymous=true; group.addremove=true; group.template="cbi/tblsection"
group:option(Value,"name",translate("Name")); local gq=group:option(Value,"quota_gb",translate("Quota (GB)")); gq.validate=quota.validate; local members=group:option(DynamicList,"mac",translate("DHCP devices")); picker(members); group:option(Flag,"enabled",translate("Enabled"))
local gused=group:option(DummyValue,"usage",translate("Usage / remaining")); function gused.cfgvalue(self,s) local macs=self.map.uci:get_list("bandwidth-control",s,"mac") or {}; local _,_,n=group_usage(macs); local q=quota_value(self.map.uci:get("bandwidth-control",s,"quota_gb")); local limit=q*1073741824; local remain=math.max(0,limit-n); local pct=q>0 and math.floor(n/limit*100) or 0; return string.format("%s / %s GB (%d%%), left %s",fmt(n),q,pct,fmt(remain)) end
local gdetail=group:option(DummyValue,"detail",translate("Down / Up / members")); function gdetail.cfgvalue(self,s) local macs=self.map.uci:get_list("bandwidth-control",s,"mac") or {}; local rx,tx=group_usage(macs); return string.format("%s / %s / %d device(s)",fmt(rx),fmt(tx),#macs) end
local gstate=group:option(DummyValue,"status",translate("Status")); function gstate.cfgvalue(self,s) local macs=self.map.uci:get_list("bandwidth-control",s,"mac") or {}; local q=quota_value(self.map.uci:get("bandwidth-control",s,"quota_gb")); local _,_,n=group_usage(macs); return q>0 and n>=q*1073741824 and translate("Quota reached") or translate("Allowed") end
function m.on_after_commit(self)
 local day=self.uci:get("bandwidth-control","main","reset_day")
 if day and day:match("^[1-9]$|^[12][0-9]$") then
  sys.call("uci set nlbwmon.@nlbwmon[0].database_interval="..util.shellquote(day).."; uci commit nlbwmon; /etc/init.d/nlbwmon restart")
 end
end
return m
