class ChartsController < ApplicationController
  def apex_area
    render template: "charts/apex/area"
  end

  def apex_bar
    render template: "charts/apex/bar"
  end

  def apex_boxplot
    render template: "charts/apex/boxplot"
  end

  def apex_bubble
    render template: "charts/apex/bubble"
  end

  def apex_candlestick
    render template: "charts/apex/candlestick"
  end

  def apex_column
    render template: "charts/apex/column"
  end

  def apex_heatmap
    render template: "charts/apex/heatmap"
  end

  def apex_line
    render template: "charts/apex/line"
  end

  def apex_mixed
    render template: "charts/apex/mixed"
  end

  def apex_pie
    render template: "charts/apex/pie"
  end

  def apex_polar_area
    render template: "charts/apex/polar_area"
  end

  def apex_radar
    render template: "charts/apex/radar"
  end

  def apex_radialbar
    render template: "charts/apex/radialbar"
  end

  def apex_scatter
    render template: "charts/apex/scatter"
  end

  def apex_sparklines
    render template: "charts/apex/sparklines"
  end

  def apex_timeline
    render template: "charts/apex/timeline"
  end

  def apex_treemap
    render template: "charts/apex/treemap"
  end

  def chartjs_area
    render template: "charts/chartjs/area"
  end

  def chartjs_bar
    render template: "charts/chartjs/bar"
  end

  def chartjs_line
    render template: "charts/chartjs/line"
  end

  def chartjs_other
    render template: "charts/chartjs/other"
  end

  def brite
  end

  def sparkline
  end
end
