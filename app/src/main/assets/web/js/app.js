let cpapData = [];
let pressureChart = null;

// Initialize Chart
function initChart() {
    const ctx = document.getElementById('pressureChart').getContext('2d');
    pressureChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Pressure (cmH2O)',
                data: [],
                borderColor: 'rgb(102, 126, 234)',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.1,
                fill: true
            }, {
                label: 'Leak (L/min)',
                data: [],
                borderColor: 'rgb(72, 187, 120)',
                backgroundColor: 'rgba(72, 187, 120, 0.1)',
                tension: 0.1,
                yAxisID: 'y1'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: { display: true, text: 'Pressure (cmH2O)' }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    title: { display: true, text: 'Leak (L/min)' },
                    grid: { drawOnChartArea: false }
                }
            }
        }
    });
}

// Show/hide loading spinner
function setLoading(show) {
    document.getElementById('loadingSpinner').classList.toggle('hidden', !show);
}

// Load data from Android
async function loadData() {
    try {
        setLoading(true);
        
        // Call native Android method
        if (window.AndroidInterface) {
            const result = await window.AndroidInterface.readSDCardData();
            cpapData = JSON.parse(result);
            displayStats();
            updateChart();
        } else {
            // For testing in browser
            const response = await fetch('samples/sample_data.json');
            cpapData = await response.json();
            displayStats();
            updateChart();
        }
    } catch (error) {
        alert('Error loading data: ' + error.message);
    } finally {
        setLoading(false);
    }
}

// Display statistics
function displayStats() {
    const grid = document.getElementById('statsGrid');
    grid.innerHTML = '';
    
    cpapData.forEach((night, index) => {
        const card = document.createElement('div');
        card.className = 'stat-card';
        card.innerHTML = `
            <h3>${night.date}</h3>
            <p>AHI: ${night.ahi.toFixed(1)}</p>
            <p>Usage: ${night.usageHours}h ${night.usageMinutes}m</p>
            <p>Avg Pressure: ${night.avgPressure.toFixed(1)} cmH2O</p>
            <p>Leak: ${night.leakRate.toFixed(1)} L/min</p>
            <label>
                <input type="checkbox" value="${index}" class="export-checkbox">
                Export this night
            </label>
        `;
        grid.appendChild(card);
    });
}

// Update chart
function updateChart() {
    if (cpapData.length === 0) return;
    
    const latestNight = cpapData[0];
    const labels = latestNight.pressureData.map((_, i) => `${i * 2}min`);
    
    pressureChart.data.labels = labels;
    pressureChart.data.datasets[0].data = latestNight.pressureData;
    pressureChart.data.datasets[1].data = latestNight.leakData;
    pressureChart.update();
}

// Export selected nights to PDF
function exportSelectedToPDF() {
    const checkboxes = document.querySelectorAll('.export-checkbox:checked');
    if (checkboxes.length === 0) {
        alert('Please select at least one night to export');
        return;
    }
    
    const selectedIndices = Array.from(checkboxes).map(cb => parseInt(cb.value));
    const selectedData = selectedIndices.map(i => cpapData[i]);
    
    generatePDF(selectedData);
}

// Export all nights to PDF
function exportAllToPDF() {
    if (cpapData.length === 0) {
        alert('No data to export');
        return;
    }
    generatePDF(cpapData);
}

// Generate PDF using jsPDF
function generatePDF(data) {
    const { jsPDF } = window.jspdf;
    
    data.forEach((night, index) => {
        const doc = new jsPDF();
        
        // Title
        doc.setFontSize(20);
        doc.text(`CPAP Report - ${night.date}`, 20, 30);
        
        // Statistics
        doc.setFontSize(12);
        doc.text(`AHI: ${night.ahi.toFixed(1)} events/hour`, 20, 50);
        doc.text(`Usage Time: ${night.usageHours}h ${night.usageMinutes}m`, 20, 65);
        doc.text(`Average Pressure: ${night.avgPressure.toFixed(1)} cmH2O`, 20, 80);
        doc.text(`Average Leak: ${night.leakRate.toFixed(1)} L/min`, 20, 95);
        
        // Add chart image if available
        const chartImage = document.getElementById('pressureChart').toDataURL('image/png');
        doc.addImage(chartImage, 'PNG', 20, 110, 170, 100);
        
        // Save file
        doc.save(`CPAP_Report_${night.date}.pdf`);
    });
}

// Event listeners
document.getElementById('loadDataBtn').addEventListener('click', loadData);
document.getElementById('exportPDFBtn').addEventListener('click', exportSelectedToPDF);
document.getElementById('exportAllPDFBtn').addEventListener('click', exportAllToPDF);

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    initChart();
});

