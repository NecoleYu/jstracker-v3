"use strict"

services = angular.module "jstracker.services", ["ngResource"]

services.factory "Host", ["$resource", ($resource) ->
  $resource "/hosts/:id?type_id=:type&browser=:browser", {id:"@id",type:"@type",browser:"@browser"}
]

services.factory "MultiHostLoader", ["Host", "$q", (Host, $q) ->
  ->
    delay = $q.defer()
    Host.query (hosts) ->
      delay.resolve(hosts)
    , ->
      delay.reject "Unable to fetch hosts"
]

services.factory "HostLoader", ["Host", "$route", "$q", (Host, $route, $q) ->
  ->
    delay = $q.defer()
    Host.get {id:$route.current.params.hostId,type:$route.current.params.type,browser:$route.current.params.browser}, (host) ->
      # Sort msgs.
      msgs =
        for k, v of host.msgs
          v.id = k
          v
      msgs.sort (a, b) -> b.count - a.count
      host.msgs = msgs
      
      delay.resolve host
    , ->
      delay.reject "Unable to fetch host with id #{host.id}"
]

#########################
# Msg

services.factory "Msg", ["$resource", ($resource) ->
  $resource "/msgs/:id", {id:"@id"}
]

services.factory "MsgLoader", ["Msg", "$route", "$q", (Msg, $route, $q) ->
  ->
    delay = $q.defer()
    Msg.get {id:$route.current.params.msgId}, (msg) ->
      delay.resolve msg
    , ->
      delay.reject "Unable to fetch msg with id #{msg.id}"
]
