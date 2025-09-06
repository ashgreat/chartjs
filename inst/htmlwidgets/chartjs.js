HTMLWidgets.widget({

  name: 'chartjs',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {
        // Debug information
        console.log('chartjs widget renderValue called');
        console.log('Chart object available:', typeof Chart);
        console.log('Widget data:', x);
        
        // Check if Chart.js is available
        if (typeof Chart === 'undefined') {
          console.error('Chart.js is not loaded!');
          console.log('Available global objects:', Object.keys(window));
          el.innerHTML = '<div style="padding: 20px; background: #fee; border: 1px solid #fcc; color: #c33;">Error: Chart.js library not loaded. Please check the package installation.<br><br>Debug info: Chart object type = ' + typeof Chart + '</div>';
          return;
        }

        // Clear any existing chart
        if (el.chart) {
          el.chart.destroy();
        }

        // Clear the element
        el.innerHTML = '';

        // Create canvas element
        var canvas = document.createElement('canvas');
        
        // Set canvas size explicitly
        canvas.width = width || 800;
        canvas.height = height || 400;
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        
        el.appendChild(canvas);

        // Set container size and styling
        el.style.width = width ? width + 'px' : '100%';
        el.style.height = height ? height + 'px' : '400px';
        el.style.position = 'relative';

        // Get 2D context
        var ctx = canvas.getContext('2d');

        try {
          // Create Chart.js instance
          el.chart = new Chart(ctx, {
            type: x.type,
            data: x.data,
            options: x.options || {}
          });

          // Store chart reference for potential updates
          el.chartData = x;
          
          console.log('Chart created successfully:', x.type);
        } catch (error) {
          console.error('Error creating chart:', error);
          el.innerHTML = '<div style="padding: 20px; background: #fee; border: 1px solid #fcc; color: #c33;">Error creating chart: ' + error.message + '</div>';
        }
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