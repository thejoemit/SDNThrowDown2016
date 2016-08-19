require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'base64'
require 'redis'

def base64(usr,pwd)
  base = usr + ":" + pwd
  basic = "Basic " + Base64.strict_encode64(base)
  return basic
end
def oauth2(usr,pwd)
  url = URI("https://10.10.2.29:8443/oauth2/token")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Post.new(url)
  request["authorization"] = base64(usr,pwd)
  request["content-type"] = 'application/json'
  request["cache-control"] = 'no-cache'
  request.body = "{\"grant_type\":\"password\",\"username\":\"" + usr + "\",\"password\":\"" + pwd + "\"}"
  oauthresponse = JSON.parse(http.request(request).read_body)
  return oauthresponse["token_type"] + " " + oauthresponse["access_token"]
end
def linkcheck()
url = URI("https://10.10.2.29:8443/NorthStar/API/v2/tenant/1/topology/1/links")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(url)
request['authorization'] = oauth2("group2","Group2")
linksresponse = JSON.parse(http.request(request).read_body)
linkscount = linksresponse.count
#puts JSON.pretty_generate(links[0])
a = 0
while a < linkscount
    if linksresponse[a]["operationalStatus"] != "Up"
        return linksresponse[a]['id']
    end
    a = a + 1
end
return -1
end
def node_stats(node)
  r = Redis.new(:host => "10.10.4.252" , :port => 6379 , :db => 0)
  array=[]
  case node
    when "NY"
      rdis_str = r.lrange('new york:ge-1/0/3:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('new york:ge-1/0/5:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('new york:ge-1/0/7:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "Houston"
      rdis_str = r.lrange('houston:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('houston:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('houston:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "Miami"
      rdis_str = r.lrange('miami:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('miami:ge-1/0/4:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('miami:ge-1/0/3:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('miami:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "Tampa"
      rdis_str = r.lrange('tampa:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('tampa:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('tampa:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "Chicago"
      rdis_str = r.lrange('chicago:ge-1/0/4:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('chicago:ge-1/0/3:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('chicago:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('chicago:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "Dallas"
      rdis_str = r.lrange('dallas:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('dallas:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('dallas:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('dallas:ge-1/0/3:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('dallas:ge-1/0/4:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "LA"
      rdis_str = r.lrange('los angeles:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('los angeles:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('los angeles:ge-1/0/2:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    when "SF"
      rdis_str = r.lrange('san francisco:ge-1/0/0:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('san francisco:ge-1/0/1:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
      rdis_str = r.lrange('san francisco:ge-1/0/3:traffic statistics',0,0)
      array << JSON.parse(rdis_str[0])
    else
      puts "Not a valid node"
    end
  return array
end
def topomapp()
  array_of_json = []
  # get the links
  url = URI("https://10.10.2.29:8443/NorthStar/API/v2/tenant/1/topology/1/links")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["authorization"] = oauth2("group2","Group2")
  request["content-type"] = 'application/json'
  request["cache-control"] = 'no-cache'
  linkresponse = JSON.parse(http.request(request).read_body)
  $l = 0
  $lnum = linkresponse.count
  # get the nodes
  url = URI("https://10.10.2.29:8443/NorthStar/API/v2/tenant/1/topology/1/nodes")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["authorization"] = oauth2("group2","Group2")
  request["content-type"] = 'application/json'
  request["cache-control"] = 'no-cache'
  nodesresponse = JSON.parse(http.request(request).read_body)
  $n = 0
  $nnum = nodesresponse.count
  while $n < $nnum  do
     nodesresponse[$n]["idInt"] = nodesresponse[$n]["nodeIndex"]
     # if has Autonomous System else "unknown"
     if nodesresponse[$n]["AutonomousSystem"].has_key?("asNumber")
      nodesresponse[$n]["asNumber"] = nodesresponse[$n]["AutonomousSystem"]["asNumber"]
     else
      nodesresponse[$n]["asNumber"] = "Unknown"
     end
     nodesresponse[$n]["score"] = 0.001 * linkresponse.select{|i| i["endA"]["node"]["id"] == nodesresponse[$n]["id"] or i["endZ"]["node"]["id"] == nodesresponse[$n]["id"]}.flatten.count
     # if has co-ordinates else null-map
     if nodesresponse[$n]["topology"].has_key?("coordinates") 
      coord = {"x"=>nodesresponse[$n]["topology"]["coordinates"]["coordinates"][0],"y"=>nodesresponse[$n]["topology"]["coordinates"]["coordinates"][1]}
     else
      coord = {"x"=>"0","y"=>"0"}
     end
     # if has protocols else null-root
     if nodesresponse[$n].has_key?("protocols")
       # flatten pcep info
      if nodesresponse[$n]["protocols"].has_key?("PCEP")
        nodesresponse[$n]["pcep_status"] = nodesresponse[$n]["protocols"]["PCEP"]["operationalStatus"]
        nodesresponse[$n]["pcep_address"] = nodesresponse[$n]["protocols"]["PCEP"]["pccAddress"]
      else 
      # pcep respond not-null for js
        nodesresponse[$n]["pcep_status"] = "Unknown"
      end
      # flatten management info
      if nodesresponse[$n]["protocols"].has_key?("management")
        nodesresponse[$n]["management"] = nodesresponse[$n]["protocols"]["management"]["address"]
      else
      # management respond not-null for js
        nodesresponse[$n]["management"] = "Unknown"
      end
      # flatten ospf management info
      if nodesresponse[$n]["protocols"].has_key?("OSPF")
        nodesresponse[$n]["ospf_rid"] = nodesresponse[$n]["protocols"]["OSPF"]["routerId"]
        nodesresponse[$n]["ospf_terid"] = nodesresponse[$n]["protocols"]["OSPF"]["TERouterId"]
      end
     end
     # take out the trash
     nodesresponse[$n].delete("protocols")
     nodesresponse[$n].delete("topology")
     nodesresponse[$n].delete("nodeIndex")
     nodesresponse[$n].delete("topoObjectType")
     nodesresponse[$n].delete("AutonomousSystem")
     nodepoint = {"data" => nodesresponse[$n],"position" => coord,"group" => "nodes","removed" => false,"selected" => false,"selectable" => true,"locked" => false,"grabbed" => false,"grabbable" => false}
     array_of_json << nodepoint
     $n+=1
end
while $l < $lnum  do
    # map the source and target node for the edge
    linkresponse[$l]["name_p"] = linkresponse[$l]["id"]
    linkresponse[$l]["status"] = linkresponse[$l]["operationalStatus"]
    linkresponse[$l]["source"] = linkresponse[$l]["endA"]["node"]["id"]
    linkresponse[$l]["target"] = linkresponse[$l]["endZ"]["node"]["id"]
    # flatten endA data of the link
    linkresponse[$l]["enda_host"] = nodesresponse.find{|i| i["id"] == linkresponse[$l]["endA"]["node"]["id"]}["hostName"]
    linkresponse[$l]["enda_ipv4"] = linkresponse[$l]["endA"]["ipv4Address"]["address"]
    ## HERERERE
    rd = node_stats(linkresponse[$l]["enda_host"])
    rd.each do |path|
      if path["interface_address"] == linkresponse[$l]["enda_ipv4"] 
      linkresponse[$l]["enda_timestamp"] = path["timestamp"]
        path["stats"].each do |stats|
          stats["input-bps"].each do |data|
            linkresponse[$l]["enda_inputbps"] = data["data"]
          end
          stats["input-pps"].each do |data|
            linkresponse[$l]["enda_inputpps"] = data["data"]
          end
          stats["input-packets"].each do |data|
            linkresponse[$l]["enda_inputpacket"] = data["data"]
          end
          stats["output-bps"].each do |data|
            linkresponse[$l]["enda_outputbps"] = data["data"]
          end
          stats["output-pps"].each do |data|
            linkresponse[$l]["enda_outputpps"] = data["data"]
          end
          stats["output-packets"].each do |data|
            linkresponse[$l]["enda_outputpacket"] = data["data"]
          end
        end
      end
    end
    linkresponse[$l]["enda_bw"] = linkresponse[$l]["endA"]["bandwidth"]
    linkresponse[$l]["enda_tem"] = linkresponse[$l]["endA"]["TEmetric"]
    linkresponse[$l]["enda_tec"] = linkresponse[$l]["endA"]["TEcolor"]
    # check endA for protocols
    if linkresponse[$l]["endA"]["protocols"].has_key?("RSVP") 
      linkresponse[$l]["enda_rsvpbw"] = linkresponse[$l]["endA"]["protocols"]["RSVP"]["bandwidth"]
    else
      linkresponse[$l]["enda_rsvpbw"] = -1
    end
    if linkresponse[$l]["endA"]["protocols"].has_key?("OSPF") 
      linkresponse[$l]["enda_ospfarea"] = linkresponse[$l]["endA"]["protocols"]["OSPF"]["area"]
      linkresponse[$l]["enda_ospftem"] = linkresponse[$l]["endA"]["protocols"]["OSPF"]["TEMetric"]
    else
      linkresponse[$l]["enda_ospfarea"] = -1
    end
    # flatten endZ data of the link
    linkresponse[$l]["endz_host"] = nodesresponse.find{|i| i["id"] == linkresponse[$l]["endZ"]["node"]["id"]}["hostName"]
    linkresponse[$l]["endz_ipv4"] = linkresponse[$l]["endZ"]["ipv4Address"]["address"]
    rd = node_stats(linkresponse[$l]["endz_host"])
    rd.each do |path|
      if path["interface_address"] == linkresponse[$l]["endz_ipv4"] 
      linkresponse[$l]["endz_timestamp"] = path["timestamp"]
        path["stats"].each do |stats|
          stats["input-bps"].each do |data|
            linkresponse[$l]["endz_inputbps"] = data["data"]
          end
          stats["input-pps"].each do |data|
            linkresponse[$l]["endz_inputpps"] = data["data"]
          end
          stats["input-packets"].each do |data|
            linkresponse[$l]["endz_inputpacket"] = data["data"]
          end
          stats["output-bps"].each do |data|
            linkresponse[$l]["endz_outputbps"] = data["data"]
          end
          stats["output-pps"].each do |data|
            linkresponse[$l]["endz_outputpps"] = data["data"]
          end
          stats["output-packets"].each do |data|
            linkresponse[$l]["endz_outputpacket"] = data["data"]
          end
        end
      end
    end
    linkresponse[$l]["endz_bw"] = linkresponse[$l]["endZ"]["bandwidth"]
    linkresponse[$l]["endz_tem"] = linkresponse[$l]["endZ"]["TEmetric"]
    linkresponse[$l]["endz_tec"] = linkresponse[$l]["endZ"]["TEcolor"]
    # check endZ for protocols
    if linkresponse[$l]["endZ"]["protocols"].has_key?("RSVP") 
      linkresponse[$l]["endz_rsvpbw"] = linkresponse[$l]["endZ"]["protocols"]["RSVP"]["bandwidth"]
    else
      linkresponse[$l]["endz_rsvpbw"] = -1
    end
    if linkresponse[$l]["endZ"]["protocols"].has_key?("OSPF") 
      linkresponse[$l]["endz_ospfarea"] = linkresponse[$l]["endZ"]["protocols"]["OSPF"]["area"]
      linkresponse[$l]["endz_ospftem"] = linkresponse[$l]["endZ"]["protocols"]["OSPF"]["TEMetric"]
    else
      linkresponse[$l]["endz_ospfarea"] = -1
    end
    # take out the trash
    linkresponse[$l].delete("endA")
    linkresponse[$l].delete("endZ")
    linkresponse[$l].delete("id")
    linkresponse[$l].delete("operationalStatus")
    linkresponse[$l]["weight"] = 1
    coord = {"x"=>"0","y"=>"0"}
    edgepoint = {"data" => linkresponse[$l],"position" => coord,"group" => "edges","removed" => false,"selected" => false,"selectable" => true,"locked" => false,"grabbed" => false,"grabbable" => false}
    array_of_json << edgepoint
    $l+=1
end
# get the lspd
url = URI("https://10.10.2.29:8443/NorthStar/API/v2/tenant/1/topology/1/te-lsps")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(url)
request["authorization"] = oauth2("group2","Group2")
request["content-type"] = 'application/json'
request["cache-control"] = 'no-cache'
lspresponse = JSON.parse(http.request(request).read_body)
$d = 0
$dnum = lspresponse.count
while $d < $dnum  do
  lspresponse[$d]["topoObjectType"] = "lsp"
  lspresponse[$d]["lsp"] = "ete"
  lspresponse[$d]["name_p"] = lspresponse[$d]["name"]
  # map the source and target node for the edge
  lspresponse[$d]["source"] = lspresponse[$d]["from"]["address"]
  lspresponse[$d]["target"] = lspresponse[$d]["to"]["address"]
  lspresponse[$d]["group"] = lspresponse[$d]["name"].split('_')[1]
  lspresponse[$d].delete("name")
  # map each lsp live info
  lspresponse[$d]["live_bw"] = lspresponse[$d]["liveProperties"]["bandwidth"]
  lspresponse[$d]["live_met"] = lspresponse[$d]["liveProperties"]["metric"]
  lspresponse[$d]["live_sp"] = lspresponse[$d]["liveProperties"]["setupPriority"]
  lspresponse[$d]["live_hp"] = lspresponse[$d]["liveProperties"]["holdingPriority"]
  lspresponse[$d]["live_status"] = lspresponse[$d]["liveProperties"]["adminStatus"]
  # map each lsp path recursivly
  coord = {"x"=>"0","y"=>"0"}
  lspresponse[$d]["liveProperties"]["ero"].each do |path|
    source = linkresponse.find{|i| i["endz_ipv4"] == path["address"] or i["enda_ipv4"] == path["address"]}["source"]
    target = linkresponse.find{|i| i["endz_ipv4"] == path["address"] or i["enda_ipv4"] == path["address"]}["target"]
      if lspresponse[$d]["group"] == "TWO"
        lsp_data = {"source"=>source.to_s,"target"=>target.to_s,"topoObjectType"=>"lsp","group"=>lspresponse[$d]["group"],"lsp"=>"Live","name_p"=>lspresponse[$d]["name_p"],"live_status"=>lspresponse[$d]["live_status"],"tunnelId"=>lspresponse[$d]["tunnelId"]}
      else
        lsp_data = {"source"=>source.to_s,"target"=>target.to_s,"topoObjectType"=>"lsp","group"=>lspresponse[$d]["group"],"name_p"=>lspresponse[$d]["name_p"],"live_status"=>lspresponse[$d]["live_status"],"tunnelId"=>lspresponse[$d]["tunnelId"]}
      end
    edgepoint = {"data" => lsp_data,"position" => coord,"group" => "edges","removed" => false,"selected" => false,"selectable" => true,"locked" => false,"grabbed" => false,"grabbable" => false}
    array_of_json << edgepoint
  end
  # take out the trash
  lspresponse[$d].delete("from")
  lspresponse[$d].delete("to")
  # take out of the trash
  lspresponse[$d].delete("plannedProperties")
  lspresponse[$d].delete("liveProperties")
  edgepoint = {"data" => lspresponse[$d],"position" => coord,"group" => "edges","removed" => false,"selected" => false,"selectable" => true,"locked" => false,"grabbed" => false,"grabbable" => false}
  array_of_json << edgepoint
  $d+=1
end
  return JSON.pretty_generate(array_of_json)
end
class Topomap
  while sleep 10
  puts "[WRITING] DO NOT USE WEBPAGE!!"
  File.open("map.json","w") do |f|
    f.write(topomapp)
  end
  puts "[LINKCHECKER] Links Down (-1 if none)"
  puts linkcheck
  puts "[IDLE] Refresh the Webpage NOW!!"
  end
end
