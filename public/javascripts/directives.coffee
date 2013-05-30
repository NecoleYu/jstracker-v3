
"use strict"

directives = angular.module "jstracker.directives", []

directives.directive "errortable", ->
  (scope, element, attrs) ->
    scope.$watch "msg", ->
      renderPie element
      renderLine element
      renderLineHourly element

directives.directive "loading", ["$rootScope", ($rootScope) ->
  (scope, element, attrs) ->
    element.addClass "hide"
    $rootScope.$on "$routeChangeStart", ->
      element.removeClass "hide"
    $rootScope.$on "$routeChangeSuccess", ->
      element.addClass "hide"
]

directives.directive "ng-view", ->
  (scope, element, attrs) ->
    scope.$watch "host", ->
      setTimeout ->
        console.log 11
        
      , 0

#########################
# Methods.

CHART_FONT = '"Lucida Grande", Helvetica, Arial, sans-serif'

renderPie = (element) ->

  el = element.find("div.pie-chart")

  if !google || !google.visualization || !el || !el[0] || !el[0].innerHTML.trim()
    return setTimeout ->
      renderPie(element)
    , 200

  data = new google.visualization.DataTable
  data.addColumn "string", "Browser"
  data.addColumn "number", "Occurrences"
  data.addRows JSON.parse el.html()
  
  pie = new google.visualization.PieChart el[0]
  pie.draw data, {
    width: '80%'
    height: 150
    chartArea:
      left: 0
      right: 0
      top: 0
      width: '100%'
      height: 150
    title: 'Occurrences across browsers'
    legend: 'right'
    legendTextStyle:
      fontName: CHART_FONT
      fontSize: 12
    pieSliceTextStyle:
      fontName: CHART_FONT
      fontSize: 12
    is3D: true
    backgroundColor: "transparent"
  }
  
renderLine = (element) ->
  el = element.find("div.line-chart")

  if !google || !google.visualization || !el || !el[0] || !el[0].innerHTML.trim()
    return setTimeout ->
      renderLine(element)
    , 200

  data = new google.visualization.DataTable
  data.addColumn "string", "Days ago"
  data.addColumn "number", "Occurrences"
  data.addRows JSON.parse el.html()

  line = new google.visualization.LineChart(el[0])
  line.draw data, {
    chartArea: {left:0, right:0, width:"83%", height: 100}
    hAxis: {
      title: "最近 15 天走势"
      titleTextStyle: {color:"#999", fontSize:12, fontName:CHART_FONT}
    }
    vAxis: {
      gradlineColor: "#f6f6f6"
      baselineColor: "#ccc"
      textPosition: "in"
      textStyle: {color:"#999", fontName:CHART_FONT}
      fontName: CHART_FONT
    }
    height: 130
  }
  
renderLineHourly = (element) ->
  el = element.find("div.line-chart-hourly")
  
  if !google || !google.visualization || !el || !el[0] || !el[0].innerHTML.trim()
    return setTimeout ->
      renderLineHourly(element)
    , 1000

  data = new google.visualization.DataTable
  data.addColumn "string", "Days ago"
  data.addColumn "number", "Occurrences"

  json = el.html().split(",")
  json = (["#{i}点钟", parseInt(item, 10)] for item, i in json)
  data.addRows json

  line = new google.visualization.LineChart(el[0])
  line.draw data, {
    chartArea: {left:0, right:0, width:"83%", height: 100}
    hAxis: {
      title: "最近 24 小时走势"
      titleTextStyle: {color:"#999", fontSize:12, fontName:CHART_FONT}
    }
    vAxis: {
      gradlineColor: "#f6f6f6"
      baselineColor: "#ccc"
      textPosition: "in"
      textStyle: {color:"#999", fontName:CHART_FONT}
      fontName: CHART_FONT
    }
    height: 130
  }


