// Main JavaScript for Personal Finance Manager

// Initialize tooltips
document.addEventListener('DOMContentLoaded', function() {
    // Bootstrap tooltip initialization
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});

// Format currency inputs
function formatCurrency(input) {
    let value = input.value.replace(/[^0-9.]/g, '');
    if (value) {
        input.value = parseFloat(value).toFixed(2);
    }
}

// Add currency formatting to all amount inputs
document.addEventListener('DOMContentLoaded', function() {
    const amountInputs = document.querySelectorAll('input[name="amount"], input[name="budget_amount"], input[name="target_amount"], input[name="contribution_amount"]');
    
    amountInputs.forEach(input => {
        input.addEventListener('blur', function() {
            formatCurrency(this);
        });
    });
});

// Confirm delete actions
function confirmDelete(message) {
    return confirm(message || 'Are you sure you want to delete this item?');
}

// Auto-dismiss alerts after 5 seconds
document.addEventListener('DOMContentLoaded', function() {
    const alerts = document.querySelectorAll('.alert:not(.alert-info):not(.alert-warning):not(.alert-secondary)');
    
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
});

// Loading spinner for forms
document.addEventListener('DOMContentLoaded', function() {
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
        form.addEventListener('submit', function() {
            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing...';
            }
        });
    });
});

// Number formatting utilities
function formatNumber(num) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(num);
}

function formatPercentage(num) {
    return num.toFixed(1) + '%';
}

// Date utilities
function getTodayString() {
    const today = new Date();
    return today.toISOString().split('T')[0];
}

function getFirstDayOfMonth() {
    const today = new Date();
    return new Date(today.getFullYear(), today.getMonth(), 1).toISOString().split('T')[0];
}

function getLastDayOfMonth() {
    const today = new Date();
    return new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split('T')[0];
}

// Validation helpers
function validateAmount(amount) {
    const num = parseFloat(amount);
    return !isNaN(num) && num > 0;
}

function validateDate(dateString) {
    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date);
}

// Chart color palette
const chartColors = {
    primary: '#667eea',
    success: '#28a745',
    danger: '#dc3545',
    warning: '#ffc107',
    info: '#17a2b8',
    secondary: '#6c757d',
    light: '#f8f9fa',
    dark: '#212529'
};

const chartColorPalette = [
    '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
    '#FF9F40', '#FF6384', '#C9CBCF', '#4BC0C0', '#FF6384'
];

// Local storage utilities
function saveToLocalStorage(key, value) {
    try {
        localStorage.setItem(key, JSON.stringify(value));
        return true;
    } catch (e) {
        console.error('Error saving to localStorage:', e);
        return false;
    }
}

function getFromLocalStorage(key) {
    try {
        const item = localStorage.getItem(key);
        return item ? JSON.parse(item) : null;
    } catch (e) {
        console.error('Error reading from localStorage:', e);
        return null;
    }
}

// Print functionality
function printReport() {
    window.print();
}

// Export to CSV (client-side)
function exportTableToCSV(tableId, filename) {
    const table = document.getElementById(tableId);
    if (!table) return;
    
    let csv = [];
    const rows = table.querySelectorAll('tr');
    
    for (let i = 0; i < rows.length; i++) {
        const row = [];
        const cols = rows[i].querySelectorAll('td, th');
        
        for (let j = 0; j < cols.length; j++) {
            row.push(cols[j].innerText);
        }
        
        csv.push(row.join(','));
    }
    
    downloadCSV(csv.join('\n'), filename);
}

function downloadCSV(csv, filename) {
    const csvFile = new Blob([csv], { type: 'text/csv' });
    const downloadLink = document.createElement('a');
    
    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = 'none';
    
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

// Smooth scroll to top
function scrollToTop() {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

// Add scroll to top button
document.addEventListener('DOMContentLoaded', function() {
    // Create button
    const scrollBtn = document.createElement('button');
    scrollBtn.innerHTML = '<i class="bi bi-arrow-up"></i>';
    scrollBtn.className = 'btn btn-primary position-fixed bottom-0 end-0 m-4';
    scrollBtn.style.display = 'none';
    scrollBtn.style.zIndex = '1000';
    scrollBtn.onclick = scrollToTop;
    
    document.body.appendChild(scrollBtn);
    
    // Show/hide on scroll
    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            scrollBtn.style.display = 'block';
        } else {
            scrollBtn.style.display = 'none';
        }
    });
});

// Console message
console.log('%c Personal Finance Manager ', 'background: #667eea; color: white; font-size: 16px; padding: 10px;');
console.log('%c Built with Flask + Bootstrap 5 + SQLite + Oracle ', 'color: #667eea; font-size: 12px;');
console.log('%c Data Management 2 Coursework © 2025 ', 'color: #6c757d; font-size: 10px;');
