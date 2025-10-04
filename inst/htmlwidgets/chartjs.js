(function() {
  function ensureChart() {
    if (typeof Chart === 'undefined') {
      throw new Error('Chart.js library is not available. Verify that chart.umd.js has been loaded.');
    }
  }

  function deepMerge(target, source) {
    if (!source) {
      return target;
    }

    Object.keys(source).forEach(function(key) {
      var value = source[key];
      if (value && typeof value === 'object' && !Array.isArray(value)) {
        target[key] = deepMerge(target[key] || {}, value);
      } else {
        target[key] = value;
      }
    });

    return target;
  }

  HTMLWidgets.widget({
    name: 'chartjs',
    type: 'output',
    factory: function(el, width, height) {
      var canvas = document.createElement('canvas');
      el.appendChild(canvas);
      el.classList.add('chartjs-widget');

      var chart = null;

      function destroyChart() {
        if (chart) {
          chart.destroy();
          chart = null;
        }
      }

      function buildChart(config) {
        ensureChart();
        destroyChart();

        if (canvas.parentNode !== el) {
          el.innerHTML = '';
          canvas = document.createElement('canvas');
          el.appendChild(canvas);
        }

        var ctx = canvas.getContext('2d');
        chart = new Chart(ctx, {
          type: config.type,
          data: config.data,
          options: config.options || {}
        });

        el.chartjsMeta = config.meta || null;
        el.chart = chart;
        return chart;
      }

      return {
        renderValue: function(x) {
          try {
            buildChart(x);
          } catch (error) {
            destroyChart();
            el.innerHTML = '<div class="chartjs-error">' + error.message + '</div>';
          }
        },

        resize: function() {
          if (chart) {
            chart.resize();
          }
        },

        getChart: function() {
          return chart;
        }
      };
    }
  });

  if (!HTMLWidgets.shinyMode) {
    return;
  }

  function withWidget(id, callback) {
    var widget = HTMLWidgets.find('#' + id);
    if (widget && typeof callback === 'function') {
      callback(widget);
    }
  }

  Shiny.addCustomMessageHandler('chartjs-update-data', function(message) {
    withWidget(message.id, function(widget) {
      var chart = widget.getChart && widget.getChart();
      if (!chart) {
        return;
      }

      var element = widget.el || (chart.canvas && chart.canvas.parentElement) || null;

      if (message.meta) {
        if (element) {
          element.chartjsMeta = message.meta;
        }
        chart.config.type = message.meta.type || chart.config.type;
      }

      chart.config.data = message.data;
      chart.update();
    });
  });

  Shiny.addCustomMessageHandler('chartjs-update-options', function(message) {
    withWidget(message.id, function(widget) {
      var chart = widget.getChart && widget.getChart();
      if (!chart || !message.options) {
        return;
      }

      chart.options = deepMerge(chart.options || {}, message.options);
      chart.update();
    });
  });

  Shiny.addCustomMessageHandler('chartjs-add-dataset', function(message) {
    withWidget(message.id, function(widget) {
      var chart = widget.getChart && widget.getChart();
      if (!chart || !message.dataset) {
        return;
      }

      chart.data.datasets = chart.data.datasets || [];
      chart.data.datasets.push(message.dataset);
      chart.update();
    });
  });

  Shiny.addCustomMessageHandler('chartjs-remove-dataset', function(message) {
    withWidget(message.id, function(widget) {
      var chart = widget.getChart && widget.getChart();
      if (!chart) {
        return;
      }

      if (chart.data.datasets && chart.data.datasets.length > message.index) {
        chart.data.datasets.splice(message.index, 1);
        chart.update();
      }
    });
  });

  document.addEventListener('click', function(event) {
    if (!event.target.closest) {
      return;
    }

    var canvas = event.target.closest('.chartjs-widget canvas');
    if (!canvas) {
      return;
    }

    var widget = HTMLWidgets.getInstance(canvas.parentElement);
    if (!widget || !widget.getChart) {
      return;
    }

    var chart = widget.getChart();
    if (!chart) {
      return;
    }

    var points = chart.getElementsAtEventForMode(event, 'nearest', { intersect: true }, true);
    if (!points.length) {
      return;
    }

    var point = points[0];
    var dataset = chart.data.datasets[point.datasetIndex];
    var value = dataset.data[point.index];

    Shiny.setInputValue(
      canvas.parentElement.id + '_click',
      {
        datasetIndex: point.datasetIndex,
        index: point.index,
        value: value,
        label: chart.data.labels ? chart.data.labels[point.index] : null
      },
      { priority: 'event' }
    );
  });
})();
