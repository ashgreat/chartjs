HTMLWidgets.widget({

  name: 'chartjs',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        // Clear any existing chart
        if (el.chart) {
          el.chart.destroy();
        }

        // Get the canvas element or create one
        var canvas = el.querySelector('canvas');
        if (!canvas) {
          canvas = document.createElement('canvas');
          el.appendChild(canvas);
        }

        // Set canvas dimensions
        canvas.width = width;
        canvas.height = height;

        // Get 2D context
        var ctx = canvas.getContext('2d');

        // Create Chart.js instance
        el.chart = new Chart(ctx, {
          type: x.type,
          data: x.data,
          options: x.options || {}
        });

        // Store chart reference for potential updates
        el.chartData = x;
      },

      resize: function(width, height) {
        if (el.chart) {
          el.chart.resize();
        }
      },

      // Add methods for Shiny integration
      getChart: function() {
        return el.chart;
      },

      updateData: function(newData) {
        if (el.chart && newData) {
          el.chart.data = newData;
          el.chart.update();
        }
      },

      updateOptions: function(newOptions) {
        if (el.chart && newOptions) {
          Object.assign(el.chart.options, newOptions);
          el.chart.update();
        }
      }

    };
  }
});

// Shiny integration for receiving messages
if (HTMLWidgets.shinyMode) {
  
  Shiny.addCustomMessageHandler('chartjs-update-data', function(message) {
    var chart = HTMLWidgets.find('#' + message.id);
    if (chart) {
      chart.updateData(message.data);
    }
  });

  Shiny.addCustomMessageHandler('chartjs-update-options', function(message) {
    var chart = HTMLWidgets.find('#' + message.id);
    if (chart) {
      chart.updateOptions(message.options);
    }
  });

  // Event handling - send click events back to Shiny
  $(document).on('click', '.chartjs canvas', function(e) {
    var widget = HTMLWidgets.getInstance(this.parentElement);
    if (widget && widget.getChart) {
      var chart = widget.getChart();
      var points = chart.getElementsAtEventForMode(e, 'nearest', { intersect: true }, true);
      
      if (points.length) {
        var point = points[0];
        var data = {
          datasetIndex: point.datasetIndex,
          index: point.index,
          value: chart.data.datasets[point.datasetIndex].data[point.index],
          label: chart.data.labels ? chart.data.labels[point.index] : null
        };
        
        Shiny.setInputValue(this.parentElement.id + '_click', data, {priority: 'event'});
      }
    }
  });
}