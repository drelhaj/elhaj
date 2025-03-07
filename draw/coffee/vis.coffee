
root = exports ? this

Plot = () ->
  width = 800
  height = 800
  data = []
  lines = null
  margin = {top: 30, right: 30, bottom: 80, left: 60}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([height,0])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  tooltip = CustomTooltip("tooltip", 240)
  mColor = "steelblue"

  mouseOver = (d,i) ->
    d3.select(this)
      .classed("active", true)
    tooltip.showTooltip(d.sentence,d3.event)

  mouseOut = (d,i) ->
    lines.selectAll(".line").classed("active",false)
    tooltip.hideTooltip()


  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData
      x1Extent = d3.extent(data, (d) -> d.x1)
      x2Extent = d3.extent(data, (d) -> d.x2)
      xScale.domain([Math.min(x1Extent[0],x2Extent[0]), Math.max(x1Extent[1], x2Extent[1])])

      y1Extent = d3.extent(data, (d) -> d.y1)
      y2Extent = d3.extent(data, (d) -> d.y2)
      yScale.domain([Math.min(y1Extent[0],y2Extent[0]), Math.max(y1Extent[1], y2Extent[1])])

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      lines = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    lines.selectAll(".line")
      .data(data).enter()
      .append("path")
      .attr("class", "line")
      .attr("stroke", mColor)
      .attr("stroke-width", 3)
      .attr("stroke-linecap", "round")
      .attr("d", (d) -> "M#{xScale(d.x1)},#{yScale(d.y1)}L#{xScale(d.x2)},#{yScale(d.y2)}")
      .on("mouseover", mouseOver)
      .on("mouseout", mouseOut)
      
    # lines.selectAll(".hline")
    #   .data(data).enter()
    #   .append("path")
    #   .attr("class", "hline")
    #   .attr("opacity", 0.0)
    #   .attr("stroke-width", 6)
    #   .attr("stroke-linecap", "round")
    #   .attr("d", (d) -> "M#{xScale(d.x1)},#{yScale(d.y1)}L#{xScale(d.x2)},#{yScale(d.y2)}")
    #   .on("mouseover", mouseOver)
    #   .on("mouseout", mouseOut)

    # $('svg .line').tipsy({
    #   gravity:'n'
    #   html:true
    #   title: () ->
    #     d = this.__data__
    #     "<strong>#{d.sentence}</strong> listens"
    # })


  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.color = (_) ->
    if !arguments.length
      return mColor
    mColor = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

# quick hack to split sentences. most of the hard work came from:
# http://stackoverflow.com/questions/11166195/regex-that-splits-long-text-in-separate-sentences-with-match
sentenceLengths = (text) ->
  text = text.replace(/['\"\‘\’]/gm,"")
  tregex = /\n|([^\r\n.!?]+([.!?]+|$))/gim
  sentences = text.match(tregex).map((s) -> s.trim())
  data = []
  sentences.forEach (s) ->
    d = {}
    d.sentence = s
    d.length = s.length
    data.push(d)
  data = data.filter (d) -> d.length > 3
  data



# real hacky way to copy the R code from original into Javascript.
# original: http://www.r-bloggers.com/sentence-drawing-function-vs-art/
# depends on complex.js library I found:
# https://github.com/patrickroberts/Javascript-Complex-Math-Library
findPositions = (data, lengthAttribute = "length", turn = -Math.PI / 2.0) ->
  one = Complex(0,1)
  currentTurn = turn
  currentPos = Complex["0"]
  currentX = 0
  currentY = 0

  data.forEach (d) ->
    d[lengthAttribute] = +(d[lengthAttribute])
    d.facing = (Math.PI / 2.0) + currentTurn
    currentTurn += turn
    mult = one.mult(Complex(d.facing,0))
    mult = Complex(0,mult.i)
    imgExp = Complex.exp(mult)
    d.move = Complex(d[lengthAttribute],0).mult(imgExp)
    currentPos = currentPos.add(d.move)
    d.pos = currentPos
    d.x2 = Math.round(d.pos.re)
    d.y2 = Math.round(d.pos.i)
    d.x1 = currentX
    d.y1 = currentY
    currentX = d.x2
    currentY = d.y2
      
  data

texts = {
  'titles':{'title':'Titles', 'file':'titles.txt', 'color':'#DF4C42'}
  'Mockingbird':{'title':'Mockingbird', 'file':'Mockingbird.txt', 'color':'#FF00FF'}
  'abstracts':{'title':'Abstracts', 'file':'abstracts.txt', 'color':'#657782'}
  'habibi':{'title':'Habibi Paper', 'file':'habibi.txt', 'color':'#70A4F2'}
  'entaomri':{'title':'Enta Omri', 'file':'entaomri.txt', 'color':'#95B6E8'}
  'amrodiab':{'title':'Amro Diab', 'file':'amrodiab.txt', 'color':'#7B5749'}
  'gatsby':{'title':'The Great Gatsby', 'file':'great_gatsby.txt', 'color':'#D1A145'}
  'brave':{'title':'Brave New World', 'file':'brave_new_world.txt', 'color':'#70A4F2'}
  'rye':{'title':'The Catcher in the Rye', 'file':'rye.txt', 'color':'#7B5749'}
  'room':{'title':'A Room of One\'s Own', 'file':'room.txt', 'color':'#95B6E8'}
  'farewell':{'title':'A Farewell to Arms', 'file':'farewell.txt', 'color':'#657782'}
  '1984':{'title':'Nineteen Eighty-Four', 'file':'1984.txt', 'color':'#DF4C42'}
}

setupText = (text) ->
  d3.select("#name").html(text.title)


$ ->

  id = decodeURIComponent(location.hash.substring(1)).trim()
  if !id
    id = 'gatsby'
    location.replace("#" + encodeURIComponent(id))
  current = texts[id]
  $("#text_select").val(id)


  plot = Plot()
  display = (error, text) ->
    setupText(current)
    plot.color(current.color)
    data = sentenceLengths(text)
    convertedData = findPositions(data)
    plotData("#vis", convertedData, plot)

  queue()
    .defer(d3.text, "text/#{current.file}")
    .await(display)

  $("#text_select").on "change", (e) ->
    id = $(this).val()
    location.replace("#" + encodeURIComponent(id))
    url = window.location.href
    console.log(url)
    window.location.href = url
    window.location.reload()

