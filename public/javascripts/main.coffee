"use strict"

app = angular.module "jstracker", ["jstracker.services", "jstracker.directives"]

app.config ["$routeProvider", ($routeProvider) ->
  $routeProvider
    .when("/", {
      controller: "HostListController"
      resolve:
        hosts: (MultiHostLoader) ->
          MultiHostLoader()
      templateUrl: "/list.html"
    })
    .when("/hosts/:hostId/types/:type/browsers/:browser", {
      controller: "HostController"
      resolve:
        host: (HostLoader) ->
          HostLoader()
      templateUrl: "/host.html"
    })
    .when("/msgs/:msgId", {
      controller: "MsgController"
      resolve:
        msg: (MsgLoader) ->
          MsgLoader()
      templateUrl: "/msg.html"
    })
]

app.controller "HostListController", ["$scope", "$location", "hosts", ($scope, $location, hosts) ->
  $scope.hosts = hosts
  # $scope.view = (id) -> $location.path "/hosts/#{id}"
]

app.controller "HostController", ["$scope", "$location", "$route", "$http", "host", ($scope, $location, $route, $http, host) ->
  $scope.host = host
  $scope.t = $route.current.params.type
  $scope.b = $route.current.params.browser
  $scope.setBrowser = (b) ->
    $location.path "/hosts/#{host.id}/types/#{$route.current.params.type}/browsers/#{b}"
  $scope.setType = (t) ->
    $location.path "/hosts/#{host.id}/types/#{t}/browsers/#{$route.current.params.browser}"
  $scope.changeType = (msg, typeId) ->
    url = "/msgs/#{msg.id}/changetype/?type_id=#{typeId}"
    $http.get(url).success (data, status) ->
      angular.element("#J_Msg_#{msg.id}").hide() if typeId != msg.type_id
      types = ["open", "closed","ignored"]
      host.types[types[msg.type_id-1]] -= 1
      host.types[types[typeId-1]]      += 1
  setTimeout ->
  #   console.log jQuery("div.sparkline span").length
    angular.element("div.sparkline span").peity "line"
  0
]

app.controller "MsgController", ["$scope", "msg", ($scope, msg) ->
  $scope.msg = msg
]
